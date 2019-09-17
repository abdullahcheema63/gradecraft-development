class GradebookExporterJob
  include Sidekiq::Worker

  def perform(user_id, course_id, filename=nil)
    user = User.find(user_id)
    course = Course.find(course_id)

    fetch_csv_data(course)
    notify_gradebook_export(user, course, filename)
  end

  private

  def fetch_csv_data(course)
    @csv_data = GradebookExporter.new.gradebook(course)
  end

  def notify_gradebook_export(user, course, filename)
    ExportsMailer
      .gradebook_export(course, user, filename, @csv_data)
      .deliver_now
  end
end
