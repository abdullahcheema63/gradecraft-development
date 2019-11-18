class GradeUpdaterJob
  include Sidekiq::Worker
  sidekiq_options queue: 'high'

  def perform(grade_id)
    grade = Grade.includes(:assignment, :student, :course).find(grade_id)

    update_scores(grade)
    notify_on_score_update(grade)
  end

  private

  def update_scores(grade)
    grade.update_student_and_team_scores
  end

  def notify_on_score_update(grade)
    GradeAnnouncement.create(grade)
    if grade.student.email_grade_notifications?(grade.course) && !grade.course.admin_disabled_grade_email?
      NotificationMailer.grade_released(grade.id).deliver_now
    end
  end
end
