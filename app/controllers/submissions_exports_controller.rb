class SubmissionsExportsController < ApplicationController
  before_action :ensure_staff?, except: :secure_download

  skip_before_action :require_login, only: :secure_download
  skip_before_action :require_course_membership, only: :secure_download
  skip_before_action :increment_page_views, only: :secure_download

  def create
    Rails.logger.debug "Submission Export Download Beginning"
    if create_submissions_export && submissions_export_job.enqueue
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

  def output_to_file(output)
    begin 
      File.write("#{Rails.root}/files/output.txt", "#{output}\n", mode: 'a')
    rescue StandardError => error
      puts "Could not write file"
      puts "#{error}"
    end
  end

  def download
    begin
      file_path = ["#{Rails.root}", "#{submissions_export.local_file_path}"]
      file_path = file_path.join "/"
      send_file file_path, filename: submissions_export.export_filename
    rescue StandardError => error
      puts "Submission Export Download Error: #{error}"
      output_to_file error
      Rails.logger.error "Submission Export Download Error: #{error}"
    end
  end

  def secure_download
    download
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

  def submissions_export_job
    @submissions_export_job ||= SubmissionsExportJob.new(
      submissions_export_id: @submissions_export.id
    )
  end

  def assignment
    @assignment ||= Assignment.find(params[:assignment_id])
  end
end
