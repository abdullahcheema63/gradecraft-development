require "sidekiq-scheduler"
require_relative "../jobs/score_recalculator_job"

class RecalculateActiveCourseScoresJob
  include Sidekiq::Worker

  LAST_UPDATED_RANGE = 24.hours.ago..Time.now

  def perform
    # call recalculate once per unique student_id, course_id combination
    unique_grades = (updated_grades.pluck(:student_id, :course_id) + updated_earned_badges.pluck(:student_id, :course_id)).uniq
    unique_grades.each { |student_id, course_id| ScoreRecalculatorJob.perform_async(student_id, course_id) }
  end

  private

  def updated_grades
    Grade.where student_visible: true, updated_at: LAST_UPDATED_RANGE
  end

  def updated_earned_badges
    EarnedBadge.student_visible.where updated_at: LAST_UPDATED_RANGE
  end
end
