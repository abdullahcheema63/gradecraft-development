module Services
  module Actions
    class CreateSubmissionFiles
      extend LightService::Action
      expects :submissions_export, :submitter_directory_names, :archive_root_dir

      executed do |context|
        submissions_export = context.submissions_export
        submitter_directory_names = context.submitter_directory_names
        archive_root_dir = context.archive_root_dir

        create_submission_files(submissions_export, submitter_directory_names, archive_root_dir)
      end

      def self.create_submission_files(submissions_export, submitter_directory_names, archive_root_dir)
        s3_manager = submissions_export.s3_manager || S3Manager::Manager.new

        submissions(submissions_export).each do |submission|
          # write the text file for the submission into the student export directory
          if submission.text_comment.present? || submission.link.present?
            create_submission_text_file(submission, submissions_export, submitter_directory_names, archive_root_dir)
          end

          if submission.submission_files.present?
            submission.process_unconfirmed_files if submission.submission_files.unconfirmed.count > 0
            create_binary_files_for_submission(submission, s3_manager, submitter_directory_names, archive_root_dir)
          end
        end
      end

      def self.create_submission_text_file(submission, submissions_export, submitter_directory_names, archive_root_dir)
        if submissions_export.use_groups
          submitter_name = submission.group.name
        else
          submitter_name = "#{submission.student.last_name}, #{submission.student.first_name}"
        end

        open(submission_text_file_path(submissions_export, submission.submitter, submitter_directory_names, archive_root_dir), "w") do |f|
          f.puts "Submission items from #{submitter_name}"

          if submission.text_comment.present?
            f.puts "\ntext comment: #{submission.text_comment}"
          end

          if submission.link.present?
            f.puts "\nlink: #{submission.link}"
          end
        end
      end

      def self.submission_text_file_path(submissions_export, submitter, submitter_directory_names, archive_root_dir)
        File.expand_path submission_text_filename(submissions_export, submitter),
          submitter_directory_path(submitter, submitter_directory_names, archive_root_dir)
      end

      def self.submission_text_filename(submissions_export, submitter)
        [
          formatted_submitter_name(submitter),
          submissions_export.formatted_assignment_name,
          "Submission Text.txt"
        ].join(" - ")
      end

      def self.formatted_submitter_name(submitter)
        Formatter::Filename.titleize submitter.name
      end

      def self.submissions(submissions_export)
        assignment = submissions_export.assignment
        team = submissions_export.team

        # debugger
        if submissions_export.use_groups
          assignment.submissions.with_group
        elsif submissions_export.team
          assignment.student_submissions_with_files_for_team(team).reject(&:unsubmitted?)
        else
          assignment.student_submissions_with_files.reject(&:unsubmitted?)
        end
      end

      def self.create_binary_files_for_submission(submission, s3_manager, submitter_directory_names, archive_root_dir)
        submission.submission_files.present.each_with_index do |submission_file, index|
          file_path = submission_binary_file_path(submitter, submission_file, index, submitter_directory_names, archive_root_dir)
          stream_s3_file_to_disk(submission_file, file_path, s3_manager)
        end
      end

      def self.submission_binary_file_path(submitter, submission_file, index, submitter_directory_names, archive_root_dir)
        # get the filename from the submission file with an index
        filename = submission_file.instructor_filename index
        submitter_directory_file_path submitter, filename, submitter_directory_names, archive_root_dir
      end

      def self.submitter_directory_file_path(student, filename, submitter_directory_names, archive_root_dir)
        File.expand_path filename, submitter_directory_path(student, submitter_directory_names, archive_root_dir)
      end

      def self.submitter_directory_path(submitter, submitter_directory_names, archive_root_dir)
        File.expand_path(submitter_directory_names[submitter.id], archive_root_dir)
      end

      def self.stream_s3_file_to_disk(submission_file, target_file_path, s3_manager)
        begin
          s3_manager.write_s3_object_to_disk(submission_file.s3_object_file_key, target_file_path)
        rescue Aws::S3::Errors::NoSuchKey
          submission_file.mark_file_missing
        end
      end
    end
  end
end
