module Services
  module Actions
    class ArchiveExportedFiles
      extend LightService::Action
      expects :submissions_export, :archive_root_dir, :expanded_archive_base_path

      executed do |context|
        puts "~~~~~~inside Archive export files ~~~~~~~ \n\n"
        submissions_export = context.submissions_export
        archive_root_dir = context.archive_root_dir
        expanded_archive_base_path = context.expanded_archive_base_path

        puts "expanded_archive_base_path: #{expanded_archive_base_path}"

        Archive::Zip.archive("#{expanded_archive_base_path}.zip", archive_root_dir)
      end
    end
  end
end
