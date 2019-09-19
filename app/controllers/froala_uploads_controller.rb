class FroalaUploadsController < ActionController::Base

    IMAGE_EXT = [".gif", ".jpeg", ".jpg", ".png", ".svg"]
  
    def upload_image
      if params[:file]
        froala_uploads_file_path = "files/uploads/froala_uploads"
        froala_downloads_route = "/download_froala_object"
        FileUtils::mkdir_p(Rails.root.join(froala_uploads_file_path))
  
        ext = File.extname(params[:file].original_filename)
        ext = image_validation(ext)
        file_name = "#{SecureRandom.urlsafe_base64}#{ext}"
        path = Rails.root.join(froala_uploads_file_path, file_name)
  
        File.open(path, "wb") {|f| f.write(params[:file].read)}
        view_file = Rails.root.join(froala_downloads_route, file_name).to_s
        render :json => {:link => view_file}.to_json
  
      else
        render :text => {:link => nil}.to_json
      end
    end
  
    def image_validation(ext)
      raise "Not allowed" unless IMAGE_EXT.include?(ext)
    end
  
    def access_file
      if File.exists?(Rails.root.join("files", "uploads", "froala_uploads", params[:name]))
        send_data File.read(Rails.root.join("files", "uploads", "froala_uploads", params[:name])), :disposition => "attachment"
      else
        render :nothing => true
      end
    end
  end