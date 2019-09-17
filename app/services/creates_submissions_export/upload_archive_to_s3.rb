module Services
  module Actions
    class UploadArchiveToS3
      extend LightService::Action
      expects :submissions_export, :expanded_archive_base_path

      executed do |context|
        submissions_export = context.submissions_export
        expanded_archive_base_path = context.expanded_archive_base_path

        submissions_export.upload_file_to_s3 "#{expanded_archive_base_path}.zip"
      end
    end
  end
end
