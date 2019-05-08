json.data @users.includes(:course_memberships) do |user|
  json.type "users"
  json.id user.id
  json.attributes do
    json.email user.email
    json.first_name user.first_name
    json.last_name user.last_name
    json.created_at user.created_at
  end

  json.relationships do
    json.course_memberships do
      json.data user.course_memberships.each do |course_membership|
        json.type "course_membership"
        json.id course_membership.course_id
      end
    end
  end
end

json.included do
  @users.each do |user|
    json.array! user.course_memberships.each do |course_membership|
      json.type "course_membership"
      json.id course_membership.course_id

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
