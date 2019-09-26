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
      if File.exists?(Rails.root.join("files", "uploads", "#{@course.id}", "froala_uploads", params[:name]))
        send_data File.read(Rails.root.join("files", "uploads", "#{@course.id}", "froala_uploads", params[:name])), :disposition => "attachment"
      else
        render :nothing => true
      end
    end

    def find_current_course
      @course = CourseRouter.current_course_for current_user
    end
  end