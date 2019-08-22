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

  def course_directory_exists(course)
    File.directory?("#{Rails.root}/files/uploads/#{course.course_number}-#{course.id}")
  end

  def new_directory_exists(course)
    File.directory?("#{Rails.root}/files/uploads/#{course.id}")
  end

  desc "Remove the course number from Courses with attachments"
  task remove_course_number: :environment do
    courses = Course.all

    courses.each do |c|
      if course_has_attchments?(c)
        old_file_path = "#{Rails.root}/files/uploads/#{c.course_number}-#{c.id}"
        puts("old file path: ", old_file_path)
        new_file_path = "#{Rails.root}/files/uploads/#{c.id}"
        puts("new file path: ", new_file_path)
        if course_directory_exists(c) && !new_directory_exists(c)
          FileUtils.cp_r old_file_path, new_file_path
        end
      end
    end
  end
end
