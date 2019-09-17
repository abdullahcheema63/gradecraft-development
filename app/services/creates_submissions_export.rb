require "light-service"
require_relative "creates_submissions_export/get_export"
require_relative "creates_submissions_export/generate_export"
require_relative "creates_submissions_export/create_temp_directories"
require_relative "creates_submissions_export/get_submitters"
require_relative "creates_submissions_export/create_submitter_directories"
require_relative "creates_submissions_export/create_submission_files"
require_relative "creates_submissions_export/remove_empty_submitter_directories"
require_relative "creates_submissions_export/generate_error_log"
require_relative "creates_submissions_export/archive_exported_files"
require_relative "creates_submissions_export/upload_archive_to_s3"
require_relative "creates_submissions_export/notify_on_completion"

module Services
  class CreatesSubmissionsExport
    extend LightService::Organizer

    def self.call(export_id)
      with(export_id: export_id).reduce(
        Actions::GetExport,
        Actions::CreateTempDirectories,
        Actions::GetSubmitters,
        Actions::GenerateExport,
        Actions::CreateSubmitterDirectories,
        Actions::CreateSubmissionFiles,
        Actions::RemoveEmptySubmitterDirectories,
        reduce_if(-> (context) { context[:errors].present? }, [
          Actions::GenerateErrorLog
        ]),
        Actions::ArchiveExportedFiles,
        Actions::UploadArchiveToS3,
        Actions::NotifyOnCompletion
      )
    end
  end
end
