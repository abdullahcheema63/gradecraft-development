json.data @instructors.includes(:course_memberships) do |instructor|
  json.type "instructors"
  json.id instructor.id
  json.attributes do
    json.id instructor.id
    json.first_name instructor.first_name
    json.last_name instructor.last_name
    json.email instructor.email
    if instructor.current_course
      json.url staff_path(instructor)
    end
    json.license_expires "soon"
    json.payment_method "Legacy"
    json.account_type "the best"
  end
  json.relationships do
    json.course_memberships do
      json.data instructor.course_memberships.each do |course_membership|
        json.type "course_membership"
        json.id course_membership.id
      end
    end
  end
end

json.included do
  @instructors.each do |instructor|
    json.array! instructor.course_memberships.each do |course_membership|
      json.type "course_membership"
      json.id course_membership.id

      course = Course.find(course_membership.course_id)
      if course.active?
        json.attributes do
          json.course_name course.name
          json.licensed course.has_paid
          json.student_count course.student_count
          json.change_course_path change_course_path(course)
        end
      end
    end
  end
end
