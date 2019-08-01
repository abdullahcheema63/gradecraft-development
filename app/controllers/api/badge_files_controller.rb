# Note: this file has been formatted as similarly to FileUploadsController as
# possible, to facilitate eventually moving BadgeFiles into this
# polymorphic model.

class API::BadgeFilesController < ApplicationController

  before_action :ensure_staff?

  # POST /api/badges/:badge_id/file_uploads
  def create
    badge = Badge.find(params[:badge_id])

    @file_uploads = []
    params[:file_uploads].each do |f|
      file = badge.badge_files.create(
        file: f,
        filename: f.original_filename[0..49]
      )
      @file_uploads << file
    end
    render "api/file_uploads/index", status: 201
  end

  # DELETE /api/badge_files/:id
  def destroy
    file = BadgeFile.where(id: params[:id]).first
    if file.present?
      file.destroy

      if file.destroyed?
        render json: { message: "Badge file successfully deleted", success: true },
        status: 200
      else
        render json: {message: "Badge file failed to delete", success: false},
        status: 400
      end
    else
      render json: {message: "Badge file not found", success: false},
      status: 400
    end
  end
end
