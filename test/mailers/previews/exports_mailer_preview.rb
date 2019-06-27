class ExportsMailerPreview < ActionMailer::Preview

  def submissions_export_success
    assignment = Assignment.first
    professor = User.with_role_in_courses("professor", Course.first).first
    submissions_export = SubmissionsExport.first
    secure_token = SecureToken.first
    ExportsMailer.submissions_export_success professor, assignment, submissions_export, secure_token
  end

  def submissions_export_failure
    assignment = Assignment.first
    professor = User.with_role_in_courses("professor", Course.first).first
    ExportsMailer.submissions_export_failure professor, assignment
  end

  def grade_export
    course = Course.first
    ExportsMailer.grade_export(
      course,
      user = User.first,
      csv_data = course.assignments.to_a.to_csv
    )
    ExportsMailer.grade_export course, user, csv_data
  end

  def gradebook_export
    course = Course.first
    ExportsMailer.gradebook_export(
      course,
      user = User.first,
      csv_data = course.assignments.to_a.to_csv
    )
    ExportsMailer.gradebook_export course, user, "gradebook_export", csv_data
  end

  def learning_objectives_outcomes_exporter
    course = Course.find(7)
    ExportsMailer.learning_objectives_outcomes_exporter(
      course,
      user = User.find(3),
      csv_data = course.learning_objectives.to_a.to_csv
    )
    ExportsMailer.learning_objectives_outcomes_exporter course, user, "learning_objectives_outcomes_exporter", csv_data
  end

  def created_courses_export
    csv_data = CreatedCoursesExporter::BASELINE_HEADERS
    ExportsMailer.created_courses_export csv_data
  end
end
