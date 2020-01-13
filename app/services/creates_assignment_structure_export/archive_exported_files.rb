module Services
  module Actions
    class ArchiveExportedFiles
      extend LightService::Action
      expects :images_directory, :course, :current_user
      promises :course, :has_images, :current_user, :export_archive_path

      executed do |context|
        if context.has_images
          puts "Context has images, archiving"
          context.export_archive_path = "#{context.images_directory}.zip"

          Archive::Zip.archive(context.export_archive_path, context.images_directory)
        else
          puts "**Context does not have images**"
          context.export_archive_path = nil
        end
      end
    end
  end
end
