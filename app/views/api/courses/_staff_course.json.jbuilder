json.type "courses"
json.id course.id.to_s

json.attributes do
  json.partial! "api/courses/course_search_attributes", course: course

  json.role current_user.role(course)
  json.active course.active?
  json.published course.published?
  json.events_this_week Event.where(course: course).this_week.count
  json.unread_announcements Announcement.unread_count_for(current_user, course)

  json.name course.name
  json.semester course.semester
  json.year course.year
  json.course_number course.course_number
  json.start_date course.start_date
  json.end_date course.end_date

  course.created_at.in_time_zone(current_user.time_zone).tap do |created_at|
    json.created_at created_at
    json.formatted_created_at l created_at
  end

  json.course_path course_path course
  json.change_course_path change_course_path course
  json.grading_status_path grading_status_path
  json.licensed course.subscription.present?

  # !! Change these to grading status attributes !!
  json.ungraded Submission.ungraded.where(course: course).count
  json.ready_for_release Grade.where(course: course, student_visible: false).count
  json.resubmissions Submission.resubmitted.where(course: course).count

end

json.relationships do
  json.assignments do
    json.data course.assignments.upcoming.each do |assignment|
      json.type "assignment"
      json.id assignment.id
    end
  end
end
