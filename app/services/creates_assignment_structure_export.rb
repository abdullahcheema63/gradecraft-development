require "light-service"
require_relative "creates_assignment_structure_export/generate_export"
# require_relative "creates_assignment_structure_export/create_images_directory"
# require_relative "creates_assignment_structure_export/archive_exported_files"
# require_relative "creates_assignment_structure_export/copy_to_local"
# require_relative "creates_assignment_structure_export/notify_on_completion"

module Services
  class CreatesAssignmentStructureExport
    extend LightService::Organizer

    def self.call(user_id, course_id, host_url, csv_file)
      with(user_id: user_id, course_id: course_id, host_url: host_url, csv_file: csv_file).reduce(
        Actions::GenerateExport
        # Actions::CreateImagesDirectory,
        # Actions::ArchiveExportedFiles,
        # Actions::CopyToLocal,
        # Actions::NotifyOnCompletion
      )
    end
  end
end
