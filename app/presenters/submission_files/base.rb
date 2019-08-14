require "showtime"

module Presenters
  module SubmissionFiles
    class Base < Showtime::Presenter
      def submission_file
        @submission_file ||= ::SubmissionFile.where(
          id: params[:submission_file_id]
        ).first
      end

      def submission
        submission_file.try(:submission)
      end

      def filename
        submission_file.instructor_filename params[:index].to_i
      end

      def mark_submission_file_missing
        return false unless submission_file
        submission_file.mark_file_missing
      end
    end
  end
end
