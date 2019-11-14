module Services
  module Actions
    class GenerateErrorLog
      extend LightService::Action
      expects :errors, :archive_root_dir

      executed do |context|
        open(error_log_path(archive_root_dir), "w") {|file| file.puts errors }
      end

      def self.error_log_path(archive_root_dir)
        File.expand_path("error_log.txt", archive_root_dir)
      end
    end
  end
end
