class LearningObjective < ActiveRecord::Base
  belongs_to :course
  belongs_to :category, class_name: "LearningObjectiveCategory", optional: true

  has_many :levels, class_name: "LearningObjectiveLevel",
    foreign_key: :objective_id, dependent: :destroy
  has_many :cumulative_outcomes, class_name: "LearningObjectiveCumulativeOutcome",
    foreign_key: :learning_objective_id, dependent: :destroy

  has_many :learning_objective_links, foreign_key: :objective_id, dependent: :destroy
  has_many :assignments, source: :learning_objective_linkable,
    source_type: Assignment.name, through: :learning_objective_links

  accepts_nested_attributes_for :learning_objective_links

  validates_presence_of :course, :name
  validate :count_to_achieve_or_points
  validates :count_to_achieve, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates_with MatchesCourseOnLinkedCategory

  scope :ordered_by_name, -> { order :name }

  def progress(student)
    if course.objectives_award_points?
      point_progress_for student
    else
      grade_outcome_progress_for student
    end
  end

  def earned_assignment_points(student)
    grades = student.grades.student_visible
                    .not_nil
                    .included_in_course_score
                    .where(assignment_id: assignments.pluck(:id))

    grades.pluck(:final_points).sum || 0
  end

  def point_progress_for(student)
    earned = earned_assignment_points student
    return "Not Started" if earned.zero?
    earned < points_to_completion ? "In Progress" : "Completed"
  end

  def grade_outcome_progress_for(student)
    cumulative_outcome = cumulative_outcomes.for_user(student.id).first
    return "Not Started" if cumulative_outcome.nil?
    return "Failed" if failed? cumulative_outcome

    cumulative_outcome
      .observed_outcomes
      .for_student_visible_grades
      .shows_proficiency
      .count < count_to_achieve ? "In Progress" : "Completed"
  end

  private

  def failed?(cumulative_outcome)
    return false if course.objectives_award_points?
    cumulative_outcome.failed?
  end

  # Ensure that objectives have either a count to achieve or a points to completion value
  def count_to_achieve_or_points
    errors.add(:base, "must have either a count_to_achieve or points_to_completion") \
      if count_to_achieve.nil? && points_to_completion.nil?
  end
end
