require 'nokogiri'

class AssignmentExporter
  attr_accessor :user, :course

  def initialize(current_user, course, host_url="")
    @course = course
    @user = current_user
    @host_url = host_url
  end

  # This format is shared with Assignment import views and functions
  FORMAT = [
    "Name", "Assignment Type", "Point Total", "Description",
    "Purpose", "Open At", "Due At",
    "Accepts Submissions", "Accept Until", "Required"
  ]

  # These headers are not used for import
  ADDITIONAL_HEADERS = [
    "Assignment Id", "Created At", "Submissions Count", "Grades Count", "Learning Objectives", "Assignment Visibility"
  ]

  def export
    CSV.generate do |csv|
      csv << FORMAT + ADDITIONAL_HEADERS
      @course.assignments.each do |a|
        csv << [
          a.name,
          a.assignment_type.name,
          a.full_points,
          remove_froala_html(a.description, "Description", a.name),
          remove_froala_html(a.purpose, "Purpose", a.name),
          formatted_date(a.open_at),
          formatted_date(a.due_at),
          a.accepts_submissions,
          formatted_date(a.accepts_submissions_until),
          a.required,
          a.id,
          formatted_date(a.created_at),
          a.submissions.submitted.count,
          a.grades.student_visible.count,
          a.learning_objectives.pluck(:name).join(','),
          visibility(a)
        ]
      end
    end
  end

  private

  def formatted_date(date)
    return nil if date.nil?
    date.in_time_zone(@user.time_zone).strftime("%m/%d/%Y")
  end

  def visibility(assignment)
    if assignment.unlock_conditions.exists?
      if !assignment.visible_when_locked
        return "Hidden when locked"
      end
      
      return "Visible when locked"
    end

    return "Visible" if assignment.visible
      
    return "Hidden"
  end

  def remove_froala_html(assignment_structure_details, type, assignment_name)
    assignment_structure_details_html = Nokogiri::HTML(assignment_structure_details)
    count = 0

    assignment_structure_details_html.search('img').each do |inline_image_upload|
      image_upload_link = @host_url + inline_image_upload['src']
      image_name = "#{assignment_name} - #{type} - Image #{count}"
      count += 1
      inline_image_upload.replace("<p> [ image inserted here is included as #{image_upload_link} in the archive ] </p>")
    end

    assignment_structure_details_html.xpath("//text()").to_s
  end
end
