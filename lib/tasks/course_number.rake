namespace :move_attachment_directories do

  def has_assignment_attchments?(course)
    course.assignments.map(&:assignment_files).any?
  end

  def has_badge_attchments?(course)
    course.badges.map(&:badge_files).any?
  end

  def has_challenge_attchments?(course)
    course.challenges.map(&:challenge_files).any?
  end

  def has_grade_attchments?(course)
    course.grades.map(&:attachments).any?
  end

  def course_has_attchments?(course)
    has_assignment_attchments?(course) || has_badge_attchments?(course) || has_challenge_attchments?(course) || has_grade_attchments?(course)
  end

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

  desc "Recursively copy directories of attachments using the course number"
  task :move_attachment_directories, [:run_it] => [:environment] do |t, args|
    courses = Course.all

    courses.each do |c|
      if course_has_attchments?(c)
        old_file_path = "#{Rails.root}/files/uploads/#{c.course_number}-#{c.id}"
        new_file_path = "#{Rails.root}/files/uploads/#{c.id}"

        if old_directory_exists(c) && !new_directory_exists(c)
          if args[:run_it] == "true"
            puts("making a copy of directory: ", old_file_path)
            puts("naming it: ", new_file_path)
            FileUtils.cp_r old_file_path, new_file_path
          end
        end

        if check_new_directory(c, old_file_path, new_file_path)
          puts("Deleting old directory: ", old_file_path)
          if args[:run_it] == "true"
            FileUtils.remove_dir old_file_path
          end
        end
      end
    end
  end
end
