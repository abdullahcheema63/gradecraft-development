require 'nokogiri'
require 'wicked_pdf'

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

      def self.get_submission_text_html(submission_text, submission_course)
        submission_html = Nokogiri::HTML(submission_text)
      
        submission_html.search('img').each do |inline_image_upload|
          froala_images_url = "/api/download_froala_object/"
          inline_image_file = (inline_image_upload['src'])[froala_images_url.length..-1]
          inline_image_file = "#{Rails.root}/files/uploads/#{submission_course}/froala_uploads/#{inline_image_file}"
          inline_image_upload.replace("<img src=\"#{inline_image_file}\"/>")
        end

        submission_html.to_s
      end

      def self.save_pdf_submission(pdf_file_path, submission)
        submission_pdf_text = "<h1>Submission #{pdf_file_path}</h1>"
        submitter_name = "#{submission.student.first_name} #{submission.student.last_name}"
        submission_pdf_text += "<h1>Submission items from #{submitter_name}</h1>"

        if submission.text_comment.present?
          submission_html = get_submission_text_html(submission.text_comment, submission.course_id)
          submission_pdf_text += "<p><em>Text Comment from #{submitter_name}</em></p>"
          submission_pdf_text += submission_html
        end

        if submission.link.present?
          submission_pdf_text += "<p>link: <a href=\"#{submission.link}\">#{submission.link}</a>"
        end

        pdf_from_submission_text = WickedPdf.new.pdf_from_string(submission_pdf_text)
        
        save_path = Rails.root.join(pdf_file_path)

        File.open(save_path, 'wb') do |file|
          file << pdf_from_submission_text
        end
      end

      def self.create_submission_files(submissions_export, submitter_directory_names, archive_root_dir)
        
        submissions(submissions_export).each do |submission|
          # write the text file for the submission into the student export directory
          if submission.text_comment.present? || submission.link.present?
            create_submission_text_file(submission, submissions_export, submitter_directory_names, archive_root_dir)
          end

          if submission.submission_files.present?
            submission.process_unconfirmed_files if submission.submission_files.unconfirmed.count > 0
            create_binary_files_for_submission(submission, submitter_directory_names, archive_root_dir)
          end
        end
      end

      def self.create_submission_text_file(submission, submissions_export, submitter_directory_names, archive_root_dir)
        if submissions_export.use_groups
          submitter_name = submission.group.name
        else
          submitter_name = "#{submission.student.last_name}, #{submission.student.first_name}"
        end

        pdf_file_location = submission_pdf_file_path(submissions_export, submission.submitter, submitter_directory_names, archive_root_dir)

        save_pdf_submission(pdf_file_location, submission)
      end


      def self.submission_pdf_file_path(submissions_export, submitter, submitter_directory_names, archive_root_dir)
        File.expand_path submission_pdf_filename(submissions_export, submitter),
          submitter_directory_path(submitter, submitter_directory_names, archive_root_dir)
      end

      def self.submission_pdf_filename(submissions_export, submitter)
        [
          formatted_submitter_name(submitter),
          submissions_export.formatted_assignment_name,
          "Submission Text.pdf"
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

      def self.create_binary_files_for_submission(submission, submitter_directory_names, archive_root_dir)
        submission.submission_files.present.each_with_index do |submission_file, index|

          destination_file_path = submission_binary_file_path(submission.submitter, submission_file, index, submitter_directory_names, archive_root_dir)
          source_file_path = "#{Rails.root}/#{submission_file.file.to_s}"
          FileUtils.cp(source_file_path, destination_file_path)
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
    end
  end
end
