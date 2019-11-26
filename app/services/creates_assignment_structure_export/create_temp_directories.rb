require "fileutils"

module Services
  module Actions
    class CreateTempDirectories
      extend LightService::Action

      expects :course_id, :user_id, :host_url, :csv_file
      promises :export_name, :export_directory, :csv_file, :course_id, :user_id, :host_url, :csv_file, :images_directory

      executed do |context|
        context.export_name = context.csv_file.delete_suffix(".csv")
        context.export_directory = [self.tmp_dir_prefix, context.export_name].join('/')
        context.images_directory = [context.export_directory, "images"].join('/')
        context.csv_file = [context.export_directory, context.csv_file].join('/')
        
        self.make_temp_directories(context)
        
      end

      def self.make_temp_directories(context)
        FileUtils.mkdir_p(self.tmp_dir_prefix)
        FileUtils.mkdir_p(context.export_directory)
        FileUtils.mkdir_p(context.images_directory)
      end

      def self.tmp_dir_prefix
        "/tmp"
      end
    end
  end
end
