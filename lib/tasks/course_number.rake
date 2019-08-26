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

  desc "Recursively copy directories of attachments using the course number"
  task :move_attachment_directories, [:run_it] => [:environment] do |t, args|

    courses = Course.all
    courses.each do |c|
      if c.has_attachments?
        puts(c.inspect)
        old_file_path = "#{Rails.root}/files/uploads/#{c.course_number}-#{c.id}"
        puts("old_file_path: ", old_file_path)

        new_file_path = "#{Rails.root}/files/uploads/#{c.id}"
        puts("new_file_path: ", new_file_path)

        if old_directory_exists(c) && !new_directory_exists(c)
          if args[:run_it] == "true"
            puts("making a copy of directory: ", old_file_path)
            puts("naming it: ", new_file_path)
            FileUtils.cp_r old_file_path, new_file_path
          end
        end

        if check_new_directory(c, old_file_path, new_file_path)
          puts("Deleting directory: ", old_file_path)
          if args[:run_it] == "true"
            FileUtils.remove_dir old_file_path
          end
        end
      end
    end
  end

  desc "Get the extra attachment directories from courses that have changed numbers"
  task :move_extra_attachments, [:run_it] => [:environment] do |t, args|

    upload_directory = "#{Rails.root}/files/uploads"
    all_directories = get_source_directories(upload_directory)

    all_directories.each do |dir|
      course_id = dir.split('-').last
      old_dir = "#{upload_directory}/#{dir}"
      puts("old dir: ", old_dir)
      new_dir = "#{upload_directory}/#{course_id}"
      puts("new dir: ", new_dir)

      if File.directory?(new_dir)
        puts("course_id directory exists")
        if args[:run_it] == "true"
          puts("copying old_dir to new dir")
          FileUtils.cp_r("#{old_dir}/.", "#{new_dir}/.")
          puts("Deleting directory: ", old_dir)
          FileUtils.remove_dir old_dir
        end
      elsif(Course.exists?(course_id))
        if((Course.find(course_id)).has_attachments?)
          puts("Course has attachments, but does not have 'new' directory")
          puts("Course number was perviously changed")
          if args[:run_it] == "true"
            puts("making a copy of directory: ", old_dir)
            puts("naming it: ", new_dir)
            FileUtils.cp_r old_dir, new_dir
            puts("Deleting directory: ", old_dir)
            FileUtils.remove_dir old_dir
          end
        end

      else
        puts("Did not find directory with just an id")
        puts("path: ", old_dir)
        puts("No attachments were found for this course")
      end
      puts("===========================================")
    end
  end
end
