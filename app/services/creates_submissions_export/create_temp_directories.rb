require "fileutils"

module Services
  module Actions
    class CreateTempDirectories
      extend LightService::Action

      expects :submissions_export
      promises :expanded_archive_base_path, :archive_root_dir, :csv_file_path

      executed do |context|
        submissions_export = context.submissions_export
        context.expanded_archive_base_path = File.expand_path(submissions_export.export_file_basename, self.make_temp_directories)
        context.archive_root_dir = FileUtils.mkdir_p(archive_root_dir_path(submissions_export)).first
        context.csv_file_path = File.expand_path("_grade_import_template.csv", context.archive_root_dir)
      end

      def self.archive_root_dir_path(submissions_export)
        File.expand_path(submissions_export.export_file_basename, self.make_temp_directories)
      end

      def self.make_temp_directories
        FileUtils.mkdir_p(self.tmp_dir_prefix).first
      end

      def self.tmp_dir_prefix
        "/tmp"
      end
    end
  end
end
