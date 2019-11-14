class GradeExportJob
  include Sidekiq::Worker

  def perform(user_id, course_id)
    user = User.find(user_id)
    course = Course.find(course_id)

    fetch_csv_data(course)
    notify_grade_export(course, user)
  end

  private

  def fetch_csv_data(course)
    @csv_data = GradesForResearchExporter.new.research_grades(course)
  end

  def notify_grade_export(course, user)
    ExportsMailer.grade_export(course, user, @csv_data).deliver_now
  end
end
