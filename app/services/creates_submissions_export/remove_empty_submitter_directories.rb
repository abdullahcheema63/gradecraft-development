module Services
  module Actions
    class RemoveEmptySubmitterDirectories
      extend LightService::Action
      expects :submitters, :submitter_directory_names, :archive_root_dir

      executed do |context|
        submitters = context.submitters
        submitter_directory_names = context.submitter_directory_names
        archive_root_dir = context.archive_root_dir

        submitters.each do |submitter|
          if submitter_directory_empty?(submitter, submitter_directory_names, archive_root_dir)
            Dir.delete submitter_directory_path(submitter, submitter_directory_names, archive_root_dir)
          end
        end
      end

      def self.submitter_directory_empty?(submitter, submitter_directory_names, archive_root_dir)
        (Dir.entries(submitter_directory_path(submitter, submitter_directory_names, archive_root_dir)) - %w{ . .. }).empty?
      end

      def self.submitter_directory_path(submitter, submitter_directory_names, archive_root_dir)
        File.expand_path(submitter_directory_names[submitter.id], archive_root_dir)
      end
    end
  end
end
