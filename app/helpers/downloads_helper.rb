module DownloadsHelper
  def allow_assignment_submissions_export(course, current_user)
    return course.export_date_range_enabled && (Rails.env.development? || course.id == 110 && (Rails.env.production? || Rails.env.staging?))
  end

  def get_course_submissions_start_date(course)
    latest_date = course.submissions.submitted.maximum("created_at")
 
    if latest_date.nil? 
      return (Date.today - 89).strftime("%Y-%m-%d")
    end

    return (latest_date - 89).strftime("%Y-%m-%d")
  end

  def get_course_submissions_latest_date(course)
    latest_date = course.submissions.submitted.maximum("created_at")
        
    if latest_date.nil?     
      return Date.today.strftime("%Y-%m-%d")
    end

    return latest_date.strftime("%Y-%m-%d")
  end

  def present_dropdown_option(field_name)
    return field_name.tr("_", " ").split.map(&:capitalize).join(' ')
  end
end