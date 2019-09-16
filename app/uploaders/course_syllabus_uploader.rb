class CourseSyllabusUploader < CarrierWave::Uploader::Base
  def store_dir
    "files/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(pdf doc docx)
  end
end
