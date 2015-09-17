class AssignmentType < ActiveRecord::Base
  acts_as_list scope: :course

  attr_accessible :max_points, :name, :description, :student_weightable, :position

  belongs_to :course, touch: true
  has_many :assignments, -> { order('position ASC') }, :dependent => :destroy
  has_many :submissions, :through => :assignments
  has_many :assignment_weights
  has_many :grades

  validates_presence_of :name
  validate :positive_max_points

  scope :student_weightable, -> { where(:student_weightable => true) }
  scope :weighted_for_student, ->(student) { joins("LEFT OUTER JOIN assignment_weights ON assignment_types.id = assignment_weights.assignment_type_id AND assignment_weights.student_id = '#{sanitize student.id}'") }

  default_scope { order 'position' }

  def self.weights_for_student(student)
    group('assignment_types.id').weighted_for_student(student).pluck('assignment_types.id, COALESCE(MAX(assignment_weights.weight), 0)')
  end

  def weight_for_student(student)
    return 1 unless student_weightable?
    assignment_weights.where(student: student).weight
  end

  def has_predictable_assignments?
    assignments.any?(&:include_in_predictor?)
  end

  #Powers the To Do list, checks if there are assignments within the next week (soon is a scope in the Assignment model)
  def has_soon_assignments?
    assignments.any?(&:soon?)
  end

  def is_capped?
    max_points.present?
  end

  # #Getting the assignment types max value if it's present, else summing all it's assignments to create the total
  def total_points
    if max_points.present?
      max_points
    else
      assignments.map{ |a| a.point_total || 0 }.sum
    end
  end

  def total_points_for_student(student)
    if max_points.present?
      max_points
    else
      if student_weightable?
        if assignment_weights.where(:student_id => student).present?
          (total_points * weight_for_student(student)).to_i
        else
          (total_points * course.default_assignment_weight).to_i
        end
      else
        total_points
      end
    end
  end

  def visible_score_for_student(student)
    score = (student.grades.released.where(:assignment_type => self).pluck('score').sum || 0)
    if max_points?
      if score < max_points
        return score
      else
        return max_points
      end
    else
      return score
    end
  end

  def raw_score_for_student(student)
    student.grades.where(:assignment_type => self).pluck('raw_score').compact.sum
  end

  def export_scores
    if student_weightable?
      CSV.generate do |csv|
        csv << ["First Name", "Last Name", "Username", "Raw Score", "Multiplied Score" ]
        course.students.each do |student|
          csv << [student.first_name, student.last_name, student.email, self.raw_score_for_student(student), self.score_for_student(student)]
        end
      end
    else
      CSV.generate do |csv|
        csv << ["First Name", "Last Name", "Username", "Raw Score" ]
        course.students.each do |student|
          csv << [student.first_name, student.last_name, student.email, self.raw_score_for_student(student)]
        end
      end
    end
  end

  def export_summary_scores(course)
    CSV.generate do |csv|
      headers = []
      headers << "First Name"
      headers << "Last Name"
      headers << "Email"
      headers << "Username"
      headers << "Team"
      course.assignment_types.sort_by { |assignment_type| assignment_type.position }.each do |a|
        headers << a.name
      end
      csv << headers
      course.students.each do |student|
        student_data = []
        student_data << student.first_name
        student_data << student.last_name
        student_data << student.email
        student_data << student.username
        student_data << student.team_for_course(course).try(:name)
        course.assignment_types.sort_by { |assignment_type| assignment_type.position }.each do |a|
          student_data << a.visible_score_for_student(student)
        end
        csv << student_data
      end
    end
  end

  private

  def positive_max_points
    if max_points? && max_points < 1
      errors.add :base, "Maximum points must be a positive number."
    end
  end
end
