require "sidekiq-scheduler"

class NotifyCreatedCoursesJob
  include Sidekiq::Worker
  sidekiq_options queue: 'low'

  def perform
    csv = CreatedCoursesExporter.new.export
    ExportsMailer.created_courses_export(csv).deliver_now
  end
end
