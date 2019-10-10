module Services
  module Actions
    class GetSubmitters
      extend LightService::Action
      expects :submissions_export
      promises :submitters, :submitter_directory_names

      executed do |context|
        submissions_export = context.submissions_export

        context.submitters = submitters(submissions_export)
        context.submitter_directory_names = submitter_directory_names(context.submitters)

        puts "~~~~~~inside GetSubmitters~~~~~~\n\n"
        puts "context.submitter_directory_name: #{context.submitter_directory_name}"
        puts "context.submitters: #{context.submitters}"
      end

      def self.submitters(submissions_export)
        team = submissions_export.team
        assignment = submissions_export.assignment

        if submissions_export.use_groups
          assignment.groups_with_files
        elsif team
          assignment.students_with_text_or_binary_files_on_team(team)
        else
          assignment.students_with_text_or_binary_files
        end
      end

      def self.submitter_directory_names(submitters)
        submitters.inject({}) do |memo, submitter|
          # check to see whether there are any duplicate student names
          total_submitters_with_name = submitters.to_a.count do |compared_submitter|
            submitter.same_name_as?(compared_submitter)
          end

          if total_submitters_with_name > 1
            memo[submitter.id] = submitter.submitter_directory_name_with_suffix
          else
            memo[submitter.id] = submitter.submitter_directory_name
          end
          memo
        end
      end
    end
  end
end
