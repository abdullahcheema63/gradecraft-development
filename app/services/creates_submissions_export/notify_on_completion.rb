module Services
  module Actions
    class NotifyOnCompletion
      extend LightService::Action
      expects :submissions_export

      executed do |context|
        submissions_export = context.submissions_export
        team = submissions_export.team

        professor = submissions_export.professor
        assignment = submissions_export.assignment

        if submissions_export.s3_object_exists?
          deliver_archive_success_mailer(submissions_export, professor, assignment, team)
        else
          deliver_archive_failed_mailer(submissions_export, professor, assignment, team)
        end
      end

      def self.deliver_archive_success_mailer(submissions_export, professor, assignment, team)
        secure_token = submissions_export.generate_secure_token

        if team
          ExportsMailer.team_submissions_export_success(
            professor, assignment, team, submissions_export, secure_token
          ).deliver_now
        else
          ExportsMailer.submissions_export_success(
            professor, assignment, submissions_export, secure_token
          ).deliver_now
        end
      end

      def self.deliver_archive_failed_mailer(submissions_export, professor, assignment, team)
        if team
          ExportsMailer.team_submissions_export_failure(
            professor, assignment, team
          ).deliver_now
        else
          ExportsMailer.submissions_export_failure(professor, assignment).deliver_now
        end
      end
    end
  end
end
