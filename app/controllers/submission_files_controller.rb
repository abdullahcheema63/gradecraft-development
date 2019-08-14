require_relative "../presenters/submission_files/base"

class SubmissionFilesController < ApplicationController
  def download
    authorize! :download, presenter.submission_file

    file_path = URI.decode(presenter.submission_file.file.path)
    send_file file_path, x_sendfile: true

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
