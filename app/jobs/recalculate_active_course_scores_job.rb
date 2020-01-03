require "sidekiq-scheduler"

class RecalculateActiveCourseScoresJob
  include Sidekiq::Worker

  def perform
    # call recalculate once per active course
    active_courses.each do |course|
      course.recalculate_active_student_scores
    end
  end

  private

  def active_courses
    Course.active
  end
end
