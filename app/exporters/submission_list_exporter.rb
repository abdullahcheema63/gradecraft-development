class SubmissionListExporter
  def initialize(course, host_url="")
    @course = course
    @host_url = host_url
  end

  def export
    CSV.generate do |csv|
      csv << baseline_headers(@course)
      @course.submissions.submitted.find_each(batch_size: 500) do |submission|
        csv << [
          submission.id,
          submission.assignment.assignment_type.name,
          submission.assignment_id,
          submission.assignment.name,
          submission.student&.email,
          submission.student_id,
          submission.group&.name,
          find_team_name(submission),
          remove_froala_html(submission.text_comment),
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

  private

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

  def remove_froala_html(comment)
    comment_html = Nokogiri::HTML(comment)

    comment_html.search('img').each do |inline_image_upload|
      puts inline_image_upload

      if inline_image_upload.nil?
        next
      end

      image_upload_link = @host_url + inline_image_upload['src']
      inline_image_upload.replace("<p> [ image inserted here can be accessed at #{image_upload_link} ] </p>")
    end

    comment_html.xpath("//text()").to_s
  end
end
