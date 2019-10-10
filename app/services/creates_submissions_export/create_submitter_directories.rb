module Services
  module Actions
    class CreateSubmitterDirectories
      extend LightService::Action
      expects :submissions_export, :submitters, :submitter_directory_names, :archive_root_dir

      executed do |context|
        puts "~~~~~~Inside CreateSubmitterDirectories ~~~~~~ \n\n"
        submissions_export = context.submissions_export
        submitters = context.submitters
        submitter_directory_names = context.submitter_directory_names
        archive_root_dir = context.archive_root_dir

        create_directories(submitters, submitter_directory_names, archive_root_dir)
        context.fail_and_return!("Missing submitter directories!") \
          unless valid_directories?(submitters, submitter_directory_names, archive_root_dir)
      end

      def self.create_directories(submitters, submitter_directory_names, archive_root_dir)
        submitters.each do |submitter|
          dir_path = submitter_directory_path(submitter, submitter_directory_names, archive_root_dir)
          puts "creates_directories dir_path: #{dir_path} \n\n"
          FileUtils.mkdir_p(dir_path) # unless Dir.exist?(dir_path) # create directory with parents
        end
      end

      def self.valid_directories?(submitters, submitter_directory_names, archive_root_dir)
        missing_submitter_directories(submitters, submitter_directory_names, archive_root_dir).empty?
      end

      def self.missing_submitter_directories(submitters, submitter_directory_names, archive_root_dir)
        submitters.inject([]) do |memo, submitter|
          memo << submitter_directory_names[submitter.id] \
            unless Dir.exist?(submitter_directory_path(submitter, submitter_directory_names, archive_root_dir))
          memo
        end
      end

      def self.submitter_directory_path(submitter, submitter_directory_names, archive_root_dir)
        File.expand_path(submitter_directory_names[submitter.id], archive_root_dir)
      end
    end
  end
end
