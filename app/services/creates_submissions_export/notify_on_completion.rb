module Services
  module Actions
    class NotifyOnCompletion
      extend LightService::Action
      expects :submissions_export

      executed do |context|

        puts "~~~~~ Inside NotifyOnCompletion ~~~~~\n\n"
        submissions_export = context.submissions_export
        team = submissions_export.team

        professor = submissions_export.professor
        assignment = submissions_export.assignment

        zip_file_path = "#{Rails.root}/#{submissions_export.local_file_path}"
        puts "zip_file_path: #{zip_file_path}"

        if File.file?(zip_file_path)
          deliver_archive_success_mailer(submissions_export, professor, assignment, team)
        else
          deliver_archive_failed_mailer(submissions_export, professor, assignment)
        end
      end

      def self.deliver_archive_success_mailer(submissions_export, professor, assignment, team)
        secure_token = submissions_export.generate_secure_token

        if team
          ExportsMailer.mail_team_submissions_export(
            professor, assignment, team
          ).deliver_now
        else
          ExportsMailer.submissions_export_success(
            professor, assignment, submissions_export
          ).deliver_now
        end
      end

      def self.deliver_archive_failed_mailer(submissions_export, professor, assignment)
        ExportsMailer.submissions_export_failure(professor, assignment).deliver_now
      end
    end
  end
end
