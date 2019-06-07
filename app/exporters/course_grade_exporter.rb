class CourseGradeExporter

  # final grades: total score + grade earned in course
  def final_grades_for_course(course, start_date, end_date)
    puts "Start Date: #{start_date}"
    puts "End Date: #{end_date}"
    
    CSV.generate do |csv|
      csv.add_row baseline_headers
      course.students.where(:created_at => start_date.beginning_of_day..end_date.end_of_day).order_by_name.each do |student|
        csv.add_row student_data(student, course)
      end
    end
  end

  private

  def baseline_headers
    ["First Name", "Last Name", "Email", "Username", "Score", "Grade", "Level", "Team",
      "Earned Badge #", "GradeCraft ID", "GradeCraft Account Created", "Last Logged In At", "Auditing" ]
  end

  def student_data(student, course)
    [student.first_name,
      student.last_name,
      student.email,
      student.username,
      student.score_for_course(course),
      student.grade_letter_for_course(course),
      student.grade_level_for_course(course),
      student.team_for_course(course).try(:name),
      student.earned_badges_for_course(course).count,
      student.id,
      student.created_at,
      student.last_course_login(course),
      student.course_memberships.where(course: course).first.auditing ? "Yes" : "No"]
  end
end