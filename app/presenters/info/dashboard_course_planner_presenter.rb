require "./lib/showtime"

class Info::DashboardCoursePlannerPresenter < Showtime::Presenter
  include Showtime::ViewContext
  include Submissions::GradeHistory

  def course
    properties[:course]
  end

  def student
    properties[:student]
  end

  def grades_for_course
    student.grades.where(course: course).instructor_modified.order_by_graded_at
  end

  def student_grades_for_course_without_resubmissions
    resubmitted_assignments = student.submissions.where(course: course).resubmitted
    graded_assignments = student.grades.where(course: course).instructor_modified.student_visible.order_by_graded_at
    if resubmitted_assignments
      remove_resubmitted_assigments(graded_assignments, resubmitted_assignments)
    else
      return graded_assignments
    end
  end

  def remove_resubmitted_assigments(graded_assignments, resubmitted_assignments)
    filtered_assignments = graded_assignments.dup
    graded_assignments.each do |grade|
      resubmitted_assignments.each do |submission|
        if grade.assignment_id == submission.assignment_id
          filtered_assignments.delete(grade)
        end
      end
    end
    ordered_grades = (filtered_assignments.sort_by &:graded_at).reverse
  end

  def check_student_grades_for_course_without_resubmissions
    student.grades.where(course: course).instructor_modified.student_visible.exists
  end

  def check_ungraded_or_resubmitted_submissions
    student.submissions.where(course: course).where.not(submitted_at: nil).ungraded.exists? || student.submissions.where(course: course).resubmitted.exists? || student.grades.where(course: course, complete: true, student_visible: false).exists?
  end

  def student_ungraded_or_resubmitted_submissions
    student_submissions = student.submissions.where(course: course).where.not(submitted_at: nil).ungraded + student.submissions.where(course: course).resubmitted + student.grades.where(course: course, complete: true, student_visible: false)
    ordered_submissions = (student_submissions.sort_by &:updated_at).reverse
  end

  def check_student_draft_submissions
    student.submissions.exists?(course: course, submitted_at: nil)
  end

  def student_draft_submissions
    student.submissions.where(course: course, submitted_at: nil)
  end

  def assignments
    properties[:assignments]
  end

  def due_dates?
    assignments.any? { |assignment| assignment.due_at? }
  end

  def grade_for(assignment)
    student.grade_for_assignment(assignment)
  end

  def course_planner_assignments
    assignments.includes(:assignment_type).select { |assignment| course_planner?(assignment) }
  end

  def my_planner_assignments
    assignments.select { |assignment| my_planner?(assignment) }
  end

  def submittable?(assignment)
    assignment.accepts_submissions? && assignment.is_unlocked_for_student?(student)
  end

  def starred?(assignment)
    assignment.is_predicted_by_student?(student)
  end

  def submitted?(assignment)
    student.submission_for_assignment(assignment).present?
  end

  def submitted_submissions_count(assignment)
    assignment.submissions.submitted.count
  end

  private

  def to_do?(assignment)
    if student
      assignment.visible_for_student?(student) && !GradeProctor.new(grade_for(assignment)).viewable?
    else
      assignment
    end
  end

  def course_planner?(assignment)
    to_do?(assignment) && assignment.soon?
  end

  def my_planner?(assignment)
    if due_dates?
      course_planner?(assignment) && starred?(assignment)
    else
      to_do?(assignment) && starred?(assignment)
    end
  end
end
