json.data @courses.includes(:earned_badges, :assignments, course_memberships: :user) do |course|
  if current_user_is_admin?
    json.partial! "api/courses/course", course: course
  else
    json.type "courses"
    json.id course.id.to_s

    json.attributes do
      json.partial! "api/courses/student_course", course: course
    end
  end
end

if current_user_is_admin?
  json.included do
    json.array! User.with_role_in_courses("staff", @courses) do |staff_member|
      json.type "staff"
      json.id staff_member.id.to_s

      json.attributes do
        json.name staff_member.name
      end
    end
  end
  json.meta do
    json.term_for_badges term_for :badges
    json.term_for_assignment term_for :assignment
    json.term_for_assignments term_for :assignments
    json.term_for_assignment_type term_for :assignment_type
  end
end
course_ids = @courses.pluck(:id)

json.included do
  @courses.where(id: course_ids).each do |course|
    json.array! course.assignments.upcoming.each do |assignment|
      json.id assignment.id
      json.type "assignment"

      json.attributes do
        json.course_id course.id
        json.name assignment.name
        json.due_at assignment.due_at
        json.student_id current_user.id
        json.assignment_status assignment.assignment_status_for_student(current_user.id)
      end
    end
  end
end
