json.data @instructors.includes(:course_memberships) do |instructor|
  json.type "instructors"
  json.id instructor.id.to_s
  json.attributes do
    json.id instructor.id.to_s
    json.first_name instructor.first_name
    json.last_name instructor.last_name
    json.created_at instructor.created_at
    json.email instructor.email
    if instructor.current_course
      json.url staff_path(instructor)
    end
    json.licensed instructor.subscription.present?
    if instructor.subscription
      json.license_expires instructor.subscription.renewal_date
      json.account_type instructor.subscription.billing_scheme_id
      json.active_courses instructor.subscription.courses.count
      if instructor.subscription.payments.length > 0
        json.payment_method instructor.subscription.payments.last.source
      end
    end
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
      json.attributes do
        json.id course.id.to_s
        json.course_name course.name
        json.licensed course.subscription.present?
        json.student_count course.student_count
        json.change_course_path change_course_path(course)
        json.active course.active?
      end
    end
  end
end
