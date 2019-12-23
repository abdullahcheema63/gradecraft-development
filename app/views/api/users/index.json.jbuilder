json.data @users.includes(:course_memberships) do |user|
  json.type "users"
  json.id user.id
  json.attributes do
    json.id user.id
    json.username user.username
    json.email user.email
    json.first_name user.first_name
    json.last_name user.last_name
    json.created_at user.created_at
    if user.course_memberships.length && user.current_course #Admins don't have paths to their user page because they have no course memberships
      if user.is_staff?(user.current_course)
        json.user_url staff_path(user)
      else user.is_student?(user.current_course)
        json.user_url student_path(user)
      end
    end
  end

  json.relationships do
    json.course_memberships do
      json.data user.course_memberships.each do |course_membership|
        json.type "course_membership"
        json.id course_membership.id
      end
    end
  end
end

json.included do
  @users.each do |user|
    json.array! user.course_memberships.each do |course_membership|
      json.type "course_membership"
      json.id course_membership.id

      course = Course.find(course_membership.course_id)
      json.attributes do
        json.score course_membership.score
        json.role course_membership.role
        json.name course.name
        json.year course.year
        json.semester course.semester
        json.change_course_path change_course_path(course)
        json.active course.active?
      end
    end
  end
end
