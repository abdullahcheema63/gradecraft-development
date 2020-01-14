class API::DashboardController < ApplicationController
  before_action :ensure_admin?, only: [:admin_new_activity]

  # GET /api/dashboard/due_this_week
  def due_this_week
    @presenter = Info::DashboardCoursePlannerPresenter.new({
      student: current_student,
      assignments: current_course.assignments.chronological,
      course: current_course,
      view_context: view_context
    })
  end

  # GET /api/dashboard/admin_new_activity
  def admin_new_activity
    @courses = Course.where("created_at > ? ", 10.days.ago)
    @instructors_count = CourseMembership.instructors.where("created_at > ? ", 10.days.ago).count
    @subscriptions_count = Subscription.where("created_at > ? ", 10.days.ago).count
    @paid_courses_count = Payment.recently_paid_courses_count
  end
end
