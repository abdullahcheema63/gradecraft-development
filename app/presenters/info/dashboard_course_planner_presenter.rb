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
    student.grades.where(course: course).instructor_modified.order_by_updated_at_date
  end

  def student_grades_for_course_without_resubmissions
    grades_for_dashboard = []
    resubmitted_assignments = []
    grades_for_dashboard << student.grades.where(course: course).instructor_modified.student_visible.order_by_updated_at_date
    resubmitted_assignments << student.submissions.where(course: course).resubmitted

    grades_for_dashboard = grades_for_dashboard.first
    resubmitted_assignments = resubmitted_assignments.first

    for grade in grades_for_dashboard do
      for resubmission in resubmitted_assignments do
        if (grade.assignment_id == resubmission.assignment_id)
          grades_for_dashboard.delete(grade)
        end
      end
    end
    return grades_for_dashboard
  end

  def student_ungraded_or_resubmitted_submissions
    submissions_for_dashboard = []
    submissions_for_dashboard << student.submissions.where(course: course).ungraded + student.submissions.where(course: course).resubmitted + student.grades.where(course: course, student_visible: false)
    submissions_for_dashboard.first
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
