module DownloadsHelper
    def get_course_submissions_earliest_date(course)
        earliest_date = course.submissions.submitted.minimum("created_at")
        
        if earliest_date.nil? 
            return Date.today.strftime("%Y-%m-%d")
        end

        return earliest_date.strftime("%Y-%m-%d")
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