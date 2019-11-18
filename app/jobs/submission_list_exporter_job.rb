class SubmissionListExporterJob
  include Sidekiq::Worker

  def perform(user_id, course_id, filename=nil)
    user = User.find(user_id)
    course = Course.includes(submissions: [:grade, :student, :group, assignment: [:assignment_type]]).find(course_id)

    fetch_csv_data(course)
    notify_submission_list_exporter(user, course, filename)
  end

  private

  attr_reader :csv_data

  def fetch_csv_data(course)
    @csv_data = SubmissionListExporter.new.export(course)
  end

  def notify_submission_list_exporter(user, course, filename)
    ExportsMailer
      .submission_list_exporter(course, user, filename, @csv_data)
      .deliver_now
  end
end
