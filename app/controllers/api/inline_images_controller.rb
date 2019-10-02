class API::InlineImagesController < ActionController::Base
    IMAGE_EXT = [".gif", ".jpeg", ".jpg", ".png", ".svg"]
  
    before_action :find_current_course

    def upload_froala_image     
      puts "Uploading: #{@course.id}"
      
      if params[:file]
        froala_uploads_file_path = "files/uploads/#{@course.id}/froala_uploads"
        froala_downloads_route = "/api/download_froala_object"
        FileUtils::mkdir_p(Rails.root.join(froala_uploads_file_path))
        ext = File.extname(params[:file].original_filename)
        ext = image_validation(ext)
        file_name = "#{SecureRandom.urlsafe_base64}#{ext}"
        path = Rails.root.join(froala_uploads_file_path, file_name)
        File.open(path, "wb") {|ff| ff.write(params[:file].read)}
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
      puts "Accessing: #{@course.id}"
      file_path = Rails.root.join("files", "uploads", "#{@course.id}", "froala_uploads", params[:name])
      
      if File.file?(file_path)
        send_data File.read(file_path), :disposition => "attachment"
      else
        render :nothing => true
      end
    end

    def remove_uploaded_file
      puts "Deleting: #{params[:name]}"
      file_path = Rails.root.join("files", "uploads", "#{@course.id}", "froala_uploads", params[:name])
      if File.file?(file_path)
        File.delete(file_path)
        render :json => {:deleted => true}.to_json
      else
        render :json => {:delete => false}.to_json
      end
    end

    def find_current_course
      @course = CourseRouter.current_course_for current_user
    end
  end