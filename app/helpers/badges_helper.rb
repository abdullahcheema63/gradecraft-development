module BadgesHelper
    def is_formatted_date_time(badge_feedback_value)
        begin
            badge_feedback_date_time = DateTime.strptime(badge_feedback_value, "%A, %B %d, %Y, %l:%M%p %:z")
            return badge_feedback_value.length == "#{badge_feedback_date_time}".length
        rescue => exception
            return false
        end

        return false
    end

    def is_auto_awarded(badge_feedback)
        badge_feedback = badge_feedback.split("Auto-awarded on ")

        if badge_feedback.length == 2 && badge_feedback[0].length == 0 && is_formatted_date_time(badge_feedback[1])
            return true
        end

        return false
    end

    def get_auto_awarded_in_user_timezone(badge_feedback)
        badge_feedback_value = badge_feedback.split("Auto-awarded on ")[1]
        badge_feedback_date_time = DateTime.strptime(badge_feedback_value, "%A, %B %d, %Y, %l:%M%p %:z")

        "Auto-awarded on #{badge_feedback_date_time.in_time_zone(current_user.time_zone)}"
    end
end
