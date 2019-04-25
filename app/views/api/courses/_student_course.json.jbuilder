json.type "courses"
json.id course.id.to_s

json.attributes do
  json.partial! "api/courses/course_search_attributes", course: course

  json.active course.active?
  json.published course.published?
  # json.has_badges course.has_badges?
  # json.has_teams course.has_teams?
  # json.has_sections course.has_teams?
  # json.student_weighted course.student_weighted?

  json.name course.name
  json.semester course.semester
  json.year course.year
  json.course_number course.course_number

  # json.total_points course.total_points
  # json.formatted_total_points points course.total_points

  # json.student_count course.student_count

  # relative to current user's timezone
  course.created_at.in_time_zone(current_user.time_zone).tap do |created_at|
    json.created_at created_at
    json.formatted_created_at l created_at
  end

  json.course_path course_path course
  json.change_course_path change_course_path course
  json.unread_announcements Announcement.unread_count_for(current_user, course)
  json.events_this_week Event.where(course: course).this_week.count

end

json.relationships do
  json.assignments do
    json.data course.assignments.upcoming.each do |assignment|
      json.type "assignment"
      json.id assignment.id
    end
  end
end
