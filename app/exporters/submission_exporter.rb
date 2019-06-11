class SubmissionExporter
  def export(course, start_date, end_date, field)
    start_date = Date.strptime(start_date, "%Y-%m-%d")
    end_date = Date.strptime(end_date, "%Y-%m-%d")

    if confirm_model_has_field(field)
      CSV.generate do |csv|
        csv << baseline_headers(course)

        if field == "graded_at"
          query = course.submissions.submitted.includes(:grade).where("grades.graded_at" => start_date.beginning_of_day..end_date.end_of_day).references(:grade)
        else
          query = course.submissions.submitted.where(field => start_date.beginning_of_day..end_date.end_of_day)
        end

        query.find_each(batch_size: 500) do |submission|
          csv << [
            submission.id,
            submission.assignment.assignment_type.name,
            submission.assignment_id,
            submission.assignment.name,
            submission.student&.email,
            submission.student_id,
            submission.group&.name,
            find_team_name(submission),
            submission.text_comment,
            submission.created_at,
            submission.updated_at,
            submission.grade&.score,
            find_graded_by_name(submission.grade&.graded_by_id),
            submission.grade&.feedback,
            submission.grade&.graded_at
          ]
        end
      end
    end
  end

  def self.get_fields_for_export
    return ["created_at", "updated_at", "submitted_at", "graded_at"]
  end

  private


  def confirm_model_has_field(field)
    return ["created_at", "updated_at", "submitted_at", "graded_at"].include?(field)
  end

  def baseline_headers(course)
    [
      "Submission ID",
      "#{course.assignment_term} Type",
      "#{course.assignment_term} ID",
      "#{course.assignment_term} Name",
      "#{course.student_term} Email",
      "#{course.student_term} ID",
      "#{course.group_term} Name",
      "#{course.team_term} Name",
      "#{course.student_term} Comment",
      "Created At",
      "Updated At",
      "Score",
      "Graded By",
      "Grader Feedback",
      "Grade Last Updated"
    ]
  end

  def find_graded_by_name(graded_by_id)
    return if graded_by_id.nil?
    User.find(graded_by_id).name
  end

  def find_team_name(submission)
    return unless submission.student.present?
    submission.student.team_for_course(submission.course)&.name
  end
end
