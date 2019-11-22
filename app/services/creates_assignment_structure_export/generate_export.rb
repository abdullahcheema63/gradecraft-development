module Services
  module Actions
    class GenerateExport
      extend LightService::Action
      expects :course_id, :user_id, :host_url, :csv_file

      executed do |context|
        current_user = User.find(context.user_id)
        course = Course.find(context.course_id)
        assignment_structure_export = AssignmentExporter.new(current_user, course, context.host_url).export 

        open(context.csv_file, "w") do |f|
          f.puts assignment_structure_export
        end

        context.fail_and_return!("Failed to create export!") \
          if !csv_created?(context.csv_file)
      end

      def self.csv_created?(csv_file)
        File.exists?(csv_file)
      end
    end
  end
end
