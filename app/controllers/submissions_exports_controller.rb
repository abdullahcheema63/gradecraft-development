class SubmissionsExportsController < ApplicationController
  before_action :ensure_staff?, except: :secure_download

  skip_before_action :require_login, only: :secure_download
  skip_before_action :require_course_membership, only: :secure_download

  def create
    if create_submissions_export && SubmissionsExporterJob.perform_async(@submissions_export.id)
      flash[:success] = "Your submissions export is being prepared. You'll receive an email when it's complete."
    else
      flash[:alert] = "Your submissions export failed to build. An administrator has been contacted about the issue."
    end

    redirect_to assignment_path(assignment)
  end

  def destroy
    if submissions_export.destroy
      flash[:success] = "Assignment export successfully deleted from server"
    else
      flash[:alert] = "Unable to delete the submissions export from the server"
    end

    redirect_to downloads_path
  end

  def download
    file_path = ["#{Rails.root}", "#{submissions_export.local_file_path}"]
    file_path = file_path.join "/"
    send_file file_path, filename: submissions_export.export_filename
  end

  def secure_download
    if secure_download_authenticator.authenticates?
      download
    else
      if secure_download_authenticator.valid_token_expired?
        flash[:alert] = "The email link you used has expired."
      else
        flash[:alert] = "The link you attempted to access does not exist."
      end
      flash[:alert] += " Please login to download the desired file."

      redirect_to root_url
    end
  end

  protected

  def secure_download_authenticator
    @secure_download_authenticator ||= SecureTokenAuthenticator.new(
      secure_token_uuid: params[:secure_token_uuid],
      secret_key: params[:secret_key],
      target_id: params[:id],
      target_class: "SubmissionsExport"
    )
  end


  def submissions_export
    @submissions_export ||= SubmissionsExport.find params[:id]
  end

  def create_submissions_export
    @submissions_export = SubmissionsExport.create(
      assignment_id: params[:assignment_id],
      course_id: current_course.id,
      professor_id: current_user.id,
      team_id: params[:team_id],
      use_groups: params[:use_groups]
    )
  end

  def assignment
    @assignment ||= Assignment.find(params[:assignment_id])
  end
end
