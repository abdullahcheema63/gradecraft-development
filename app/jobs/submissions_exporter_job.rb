require_relative "../services/creates_submissions_export"

class SubmissionsExporterJob
  include Sidekiq::Worker
  sidekiq_options retry: 5

  attr_reader :errors

  def initialize
    puts "submissions exporter job initialized"
  end

  def perform(submission_export_id)
    Services::CreatesSubmissionsExport.call submission_export_id
  end
end
