module Services
  module Actions
    class GenerateExport
      extend LightService::Action
      expects :submissions_export, :csv_file_path

      executed do |context|
        submissions_export = context.submissions_export
        csv_file_path = context.csv_file_path


        generate(submissions_export, csv_file_path)
        context.fail_and_return!("Failed to create export!") \
          if !csv_created?(csv_file_path)
      end

      def self.generate(submissions_export, csv_file_path)
        assignment = submissions_export.assignment

        open(csv_file_path, "w") do |f|
          if submissions_export.use_groups
            export_data = GradeExporter.new
              .export_group_grades(assignment, submitters_for_csv(submissions_export))
            f.puts export_data
          else
            f.puts assignment.grade_import(submitters_for_csv(submissions_export))
          end
        end
      end

      def self.submitters_for_csv(submissions_export)
        course = submissions_export.course
        team = submissions_export.team

        if submissions_export.use_groups
          Group.where course: course
        elsif team
          User.students_being_graded_for_course(course, team)
        else
          User.students_being_graded_for_course(course)
        end
      end

      def self.csv_created?(csv_file_path)
        File.exist?(csv_file_path)
      end
    end
  end
end
