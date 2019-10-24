json.data @courses do |course|
  json.type "courses"
  json.id course.id.to_s
  json.attributes do
    json.id course.id
    json.active course.active?
    json.published course.published?
    json.subscribed course.subscription.present?
    json.name course.name
    json.semester course.semester
    json.year course.year
    json.course_number course.course_number
    json.student_count course.student_count
    course.created_at.in_time_zone(current_user.time_zone).tap do |created_at|
      json.created_at created_at
      json.formatted_created_at l created_at
    end
    json.edit_course_path edit_course_path course
    json.change_course_path change_course_path course
  end

  json.relationships do
    json.staff do
      json.data course.staff.order_by_name do |staff_member|
        json.type "staff"
        json.id staff_member.id.to_s
      end
    end if course.staff.any?
  end
end
json.included do
  json.array! User.with_role_in_courses("staff", @courses) do |staff_member|
    json.type "staff"
    json.id staff_member.id.to_s

    json.attributes do
      json.name staff_member.name
      json.id staff_member.id
      json.url staff_path(staff_member)
    end
  end
end
json.subscriptions_count @subscriptions_count
json.instructors_count @instructors_count
