class GradebookExporter

  #gradebook spreadsheet export for course
  def gradebook(course_id)
    course = fetch_course(course_id)
    CSV.generate do |csv|
      csv << gradebook_columns(course)
      course.students.each do |student|
        csv << base_column_data_for(student, course) + standard_grade_data_for(student, course)
      end
    end
  end

  private

  def fetch_course(course_id)
    Course.find(course_id)
  end

  def base_assignment_columns
    ["First Name", "Last Name", "Email", "Username", "Team"]
  end

  def assignments
    @assignments ||= @course.assignments.sort_by(&:created_at)
  end

  def gradebook_columns(course)
    base_assignment_columns + assignment_name_columns(course)
  end

  def assignment_name_columns(course)
    course.assignments.collect(&:name)
  end

  def base_column_data_for(student, course)
    student_data << [student.first_name, student.last_name, student.email, student.username, student.team_for_course()]
  end

  def standard_grade_data_for(student, course)
    course.assignments.inject(student_data) do |memo, assignment|
      grade = assignment.grade_for_student(student)
      if grade and grade.is_student_visible?
        memo << grade.try(:raw_score)
      else
        memo << ''
      end
      memo
    end
  end
end
