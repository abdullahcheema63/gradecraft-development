require_relative "../services/creates_submissions_export"

class SubmissionsExporterJob
  include Sidekiq::Worker
  sidekiq_options retry: 5

  attr_reader :errors

  def initialize
    S3fs.ensure_tmpdir # make sure the s3fs tmpdir exists
  end

  def perform(submission_export_id)
    Services::CreatesSubmissionsExport.call submission_export_id
  end
end
