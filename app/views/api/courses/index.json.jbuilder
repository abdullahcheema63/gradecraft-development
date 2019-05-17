json.data @courses.includes(:earned_badges, :assignments, course_memberships: :user) do |course|
  if current_user_is_admin?
    json.partial! "api/courses/course", course: course
  else
    if current_user.is_staff?(course)
      json.partial! "api/courses/staff_course", course: course
    else
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
        json.url staff_path(staff_member)
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
    if current_user.is_staff?(course)
      json.array! course.assignments.upcoming.each do |assignment|
        json.id assignment.id
        json.type "assignment"

        json.attributes do
          json.name assignment.name
          json.due_at assignment.due_at
          json.planned assignment.planned_assignments_count
          json.submitted assignment.submission_count
          json.graded nil # Not yet desired to show for instructors
        end
      end
    else
      json.array! course.assignments.upcoming.each do |assignment|
        json.id assignment.id
        json.type "assignment"

        json.attributes do
          json.name assignment.name
          json.due_at assignment.due_at
          json.planned assignment.has_student_predicted_grade?(current_user.id)
          json.submitted current_user.submission_for_assignment(assignment)
          #Long & complex query could be optomized ? - returns whole submission vs just .exists?
          json.graded assignment.has_student_grade?(current_user.id)
        end
      end
    end
  end
end
