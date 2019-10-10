require "fileutils"

module Services
  module Actions
    class CreateTempDirectories
      extend LightService::Action
      expects :submissions_export
      promises :expanded_archive_base_path, :archive_root_dir, :csv_file_path

      executed do |context|
        submissions_export = context.submissions_export

        puts "inside create_temp_directories"
        puts "submissions_export.export_file_basename: #{submissions_export.export_file_basename} \n\n"

        context.expanded_archive_base_path = File.expand_path(submissions_export.export_file_basename, FileManager.make_temp_directories)

        puts "archive_root_dir_path: #{archive_root_dir_path(submissions_export)}"
        context.archive_root_dir = FileUtils.mkdir_p(archive_root_dir_path(submissions_export)).first
        puts "context.archive_root_dir: #{context.archive_root_dir}"
        context.csv_file_path = File.expand_path("_grade_import_template.csv", context.archive_root_dir)
      end

      def self.archive_root_dir_path(submissions_export)
        puts "inside archive_root_dir_path, submissions_export: #{submissions_export.inspect} \n\n"
        File.expand_path(submissions_export.export_file_basename, FileManager.make_temp_directories)
      end
    end
  end
end
