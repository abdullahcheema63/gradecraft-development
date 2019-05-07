json.data @users do |user|
  json.type "users"
  json.id user.id
  json.attributes do
    json.email user.email
    json.first_name user.first_name
    json.last_name user.last_name
  end
  json.included do
    json.array! user.course_memberships.each do |course_membership|
      json.id course_membership.course_id
      json.type "course"

      course = Course.find(course_membership.course_id)
      json.attributres do
        json.score course_membership.score
        json.role course_membership.role
        json.name course.name
        json.year course.year
        json.semester course.semester
        json.change_course_path change_course_path(course)
      end
    end
  end
end
