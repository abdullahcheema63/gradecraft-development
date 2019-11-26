require "fileutils"

module Services
  module Actions
    class CreateTempDirectories
      extend LightService::Action

      expects :course_id, :user_id, :host_url, :csv_file
      promises :csv_file, :images_directory, :course_id, :user_id, :host_url

      executed do |context|
        images_export_directory_name = "#{context.csv_file.delete_suffix(".csv")} Images "
        context.images_directory = [self.tmp_dir_prefix, images_export_directory_name].join('/')
        context.csv_file = [self.tmp_dir_prefix, context.csv_file].join('/')
        
        self.make_temp_directories(context)
        
      end

      def self.make_temp_directories(context)
        FileUtils.mkdir_p(self.tmp_dir_prefix)
        FileUtils.mkdir_p(context.images_directory)
      end

      def self.tmp_dir_prefix
        "/tmp"
      end
    end
  end
end
