class AttachmentUploader < CarrierWave::Uploader::Base
  # NOTE: course, assignment and assignment_file_type, and student should be
  # defined on the model in order to use them as subdirectories, otherwise
  # they will be ommited: submission_file: files/uploads/<course-name_id>/assignments/<assignment-name_id>/submission_files/<student_name>/timestamp_file_name.ext
  # assignment_file:  files/uploads/<course_id>/assignments/<assignment_id>/assignment_files/<timestamp_file-name.ext>
  # attachment/file_upload: files/uploads/<course_id>/assignments/<assignment_id>/attachments/<timestamp_file-name.ext>
  # badge_file: files/uploads/<course_id>/badge_files/badge_id/<timestamp_file-name.ext>
  # challenge_file: files/uploads/<course_id>/challenge_files/<timestamp_file-name.ext>
  # submission_file: files/uploads/<course_id>/assignments/<assignment_id>/submission_files/<submission_id>/<timestamp_file-name.ext>

  attr_accessor :course, :assignment

  def store_dir
    store_dir_pieces.join "/"
  end

  # Override the filename of the uploaded files:
  def filename
    if original_filename.present?
      if model && model.read_attribute(mounted_as).present?
        model.read_attribute(mounted_as)
      else
        "#{tokenized_name}.#{file.extension}"
      end
    end
  end

  # these are the components of the path where resources that have mounted this
  # uploader will be stored
  def store_dir_pieces
    [
      store_dir_prefix,
      course,
      assignment,
      file_klass,
      owner_name
    ].compact
  end

  def store_dir_prefix
    return "files/uploads"
  end

  def course
    # rubocop:disable AndOr
    "#{model.course.id}" if model and model.class.method_defined? :course and model.course
  end

  # Before EFS Assignment name was added into directory path, used for submission_file and submisison_attachments
  # now only the assignment ID is used
  def assignment
    "assignments/#{model.assignment.id}" if model.class.method_defined? :assignment
  end

  # adds model name like assignment_files
  def file_klass
    return model.klass_name if model.class.method_defined? :klass_name
    klass_name = model.class.to_s.underscore.pluralize
  end

  # Before EFS, User's name or group name were put into directory path for a submission_file
  # Changing to put in submission ID
  def owner_name
    model.owner_name if model.class.method_defined? :owner_name
  end

  def tokenized_name
    model.instance_variable_get(secure_token_name) || model.instance_variable_set(secure_token_name, filename_from_basename)
  end

  def filename_from_basename
    "#{Time.now.to_i}_#{file.basename.gsub(/\W+/, "_").downcase[0..40]}"
  end

  def secure_token_name
    :"@#{mounted_as}_secure_token"
  end

  def extension_black_list
    %w(action apk app application bat bin cmd com command cpl csh dmg exe
    gadget hta inf ins inx ipa isu jar job jse lnk msc msh msh1 msh2 mshxml
    msh1xml msh2xml msi msp mst osx out paf pif prg psc1 psc2 ps1 ps1xml ps2
    ps2xml reg rgs run scf scr sct shb shs u3p vb vbe vbs vbscript workflow ws
    wsc wsf wsh)
  end
end
