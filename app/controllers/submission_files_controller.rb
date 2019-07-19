require_relative "../presenters/submission_files/base"

class SubmissionFilesController < ApplicationController
  def download
    authorize! :download, presenter.submission_file

    # let's use the object_stream here because there's no reason to hit S3 twice
    #if presenter.submission_file_streamable?
      # rubocop:disable AndOr
    send_file "#{Rails.root}#{presenter.submission_file.file.to_s}", x_sendfile: true

    #send_data(*presenter.send_data_options) and return
    #else
    #  presenter.mark_submission_file_missing
    #  flash[:alert] = "The requested file was not found on the server."
    #  redirect_to request.referrer
    #end
  end

  def presenter
    @presenter ||= Presenters::SubmissionFiles::Base.new params: params
  end
end
