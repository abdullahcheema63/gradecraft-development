namespace :move_attachment_directories do

  def old_directory_exists(course)
    File.directory?("#{Rails.root}/files/uploads/#{course.course_number}-#{course.id}")
  end

  def new_directory_exists(course)
    File.directory?("#{Rails.root}/files/uploads/#{course.id}")
  end

  def check_new_directory(course, old_dir, new_dir)
    if old_directory_exists(course) && new_directory_exists(course)
      return (File.size?(old_dir) == File.size?(new_dir))
    end
    false
  end

  def get_source_directories(upload_dir)
    Dir.chdir(upload_dir) do
      Dir.glob('*').select { |f| File.directory?(f) && f.include?('-') }
    end
  end

  def base_dir
    "#{Rails.root}/files/uploads"
  end

  #/gradecraft-development/files/uploads/<course_id>/assignments/<assignment_id>/assignment_files/
  def build_assignment_path(course_id, assignment_id)
    path = [
      base_dir,
      course_id.to_s,
      "assignments",
      assignment_id.to_s,
      "assignment_files/"
    ]
    path.join "/"
  end

  #/gradecraft-development/files/uploads/<course_id>/badge_files/<badge_id>/
  def build_badge_path(course_id, badge_id)
    path = [
      base_dir,
      course_id.to_s,
      "badge_files/",
    ].compact
    path.join "/"
  end

  #/gradecraft-development/files/uploads/<course_id>/challenge_files/
  def build_challange_path(course_id)
    path = [
      base_dir,
      course_id.to_s,
      "challenge_files/",
    ].compact
    path.join "/"
  end

  #/gradecraft-development/files/uploads/<course_id>/assignments/<assignment_id>/attachments/
  def build_file_upload_path(course_id, assignment_id)
    path = [
      base_dir,
      course_id.to_s,
      "assignments",
      assignment_id.to_s,
      "attachments/"
    ].compact
    path.join "/"
  end

  #/gradecraft-development/files/uploads/<course_id>/assignments/<assignment_id>/submission_files/<submission_id>
  def build_submission_path(course_id, assignment_id, submission_id)
    path = [
      base_dir,
      course_id.to_s,
      "assignments",
      assignment_id.to_s,
      "submission_files",
      submission_id.to_s
    ].compact
    path = path.join "/"
    path << "/"
  end


  desc "Go through the course numbers in the files directory and move them to a better directory"
  task :move_extra_attachments, [:run_it] => [:environment] do |t, args|

    auditFile = "#{Rails.root}/files/AttachmentTask.txt"
    taskAuditFile = File.open(auditFile, 'w')

    upload_directory = "#{Rails.root}/files/uploads"
    all_course_directories = get_source_directories(upload_directory)
    taskAuditFile.puts("all_course_directories: #{all_course_directories}")

    deleted_course_ids = []
    no_attachment_course_ids = []

    all_course_directories.each do |dir|
      course_id = dir.split('-').last

      if Course.exists?(course_id)
        course = Course.find(course_id)
      else
        deleted_course_ids << course_id
      end

      if course && course.has_attachments?
        taskAuditFile.puts("course #{course_id} has attachments")

        if course.has_assignment_attachments?
          course.assignments.each do |assignment|
            if assignment.assignment_files.present?
              assignment.assignment_files.each do |af|
                taskAuditFile.puts("moving assignment file: #{af.inspect}")
                new_path = build_assignment_path(course_id, assignment.id)
                new_path << af.file.file.filename
                taskAuditFile.puts("to this new path: #{new_path}")
                if args[:run_it] == "true"
                  af.file.file.move_to(new_path)
                end
                taskAuditFile.puts("---------------------------")
              end
            end
          end
        end

        if course.has_badge_attachments?
          course.badges.each do |badge|
            if badge.badge_files.present?
              badge.badge_files.each do |bf|
                taskAuditFile.puts("moving badge file: #{bf.inspect}")
                new_path = build_badge_path(course_id, badge.id)
                new_path << bf.file.file.filename
                taskAuditFile.puts("to this new path: #{new_path}")
                if args[:run_it] == "true"
                  bf.file.file.move_to(new_path)
                end
                taskAuditFile.puts("---------------------------")
              end
            end
          end
        end

        if course.has_grade_attachments?
          course.grades.each do |grade|
            if grade.file_uploads.present?
              grade.file_uploads.each do |fu|
                taskAuditFile.puts("moving grade file upload: #{fu.inspect}")
                new_path = build_file_upload_path(course_id, grade.assignment.id)
                new_path << fu.file.file.filename
                taskAuditFile.puts("to this new path: #{new_path}")
                if args[:run_it] == "true"
                  fu.file.file.move_to(new_path)
                end
                taskAuditFile.puts("---------------------------")
              end
            end
          end
        end

        if course.has_submission_attachments?
          course.submissions.each do |sub|
            if sub.submission_files.present?
              sub.submission_files.each do |sf|
                taskAuditFile.puts("moving submission file: #{sf.inspect}")
                new_path = build_submission_path(course_id, sub.assignment.id, sub.id)
                new_path << sf.file.file.filename
                taskAuditFile.puts("to this new path: #{new_path}")
                if args[:run_it] == "true"
                  sf.file.file.move_to(new_path)
                end
                taskAuditFile.puts("---------------------------")
              end
            end
          end
        end

      else
        old_dir = "#{upload_directory}/#{dir}"
        taskAuditFile.puts("course #{course_id} has no attachments")
        no_attachment_course_ids << course_id
        if Dir.empty?(old_dir)
          taskAuditFile.puts("directory is empty")
          taskAuditFile.puts("deleteing directory: #{old_dir}")
          if args[:run_it] == "true"
            FileUtils.remove_dir old_dir
          end
        end
      end

    end

    challenge_files = ChallengeFile.all

    challenge_files.each do |cf|
      taskAuditFile.puts("moving challenge file: #{cf.inspect}")
      course_id = cf.challenge.course.id
      new_path = build_challange_path(course_id)
      new_path << cf.file.file.filename
      taskAuditFile.puts("to this new path: #{new_path}")
      cf.file.file.move_to(new_path)
      taskAuditFile.puts("---------------------------")
    end

    taskAuditFile.puts("Course ID's of courses that were deleted but still in files/uploads: #{deleted_course_ids}")
    taskAuditFile.puts("Course ID's of courses still have a folder in files/uploads but do not have attachments in the DB: #{no_attachment_course_ids}")

  end

  desc "Go through the files/uploads and remove empty directorys"
  task :delete_empty_directories, [:run_it] => [:environment] do |t, args|

    auditFile = "#{Rails.root}/files/DeleteDirectories.txt"
    taskAuditFile = File.open(auditFile, 'w')

    upload_directory = "#{Rails.root}/files/uploads"

    Dir.chdir(upload_directory) do
      Dir.glob('*').select { |folder_name|
        path = upload_directory + "/" + folder_name

        taskAuditFile.puts("checking old path: #{path}")

        size = `du -s #{path.shellescape}`
        taskAuditFile.puts("size of old path: #{size}")

        if(size.chars.first == "0")
          taskAuditFile.puts("path is empty")
          taskAuditFile.puts("deleting directory #{path}")
          if args[:run_it] == "true"
            FileUtils.remove_dir path
          end
        end
      }
    end
  end
end
