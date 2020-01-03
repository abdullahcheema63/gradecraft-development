require "sidekiq-scheduler"
require_relative "../jobs/score_recalculator_job"

class RecalculateRecentlyUpdatedScoresJob
  include Sidekiq::Worker

  LAST_UPDATED_RANGE = 24.hours.ago..Time.now

  def perform
    # call recalculate once per unique student_id, course_id combination
    teams = []
    updated_challenge_grades.each do |challenge_grade|
      teams << challenge_grade.team
    end
    teams = teams.uniq
    # ? For some reason a team from this returns a nil student id in the unique_grades below
    unique_grades = (updated_grades.pluck(:student_id, :course_id) + updated_earned_badges.pluck(:student_id, :course_id) + teams.pluck(:student_id, :course_id)).uniq
    unique_grades.each { |student_id, course_id| ScoreRecalculatorJob.perform_async(student_id, course_id) }
  end

  private

  def updated_grades
    Grade.where student_visible: true, updated_at: LAST_UPDATED_RANGE
  end

  def updated_earned_badges
    EarnedBadge.student_visible.where updated_at: LAST_UPDATED_RANGE
  end

  def updated_challenge_grades
    grades_added_to_student_score = []
    ChallengeGrade.where(updated_at: LAST_UPDATED_RANGE).each do |challenge_grade|
      grades_added_to_student_score << challenge_grade if challenge_grade.contributes_to_student_score?
    end
    return grades_added_to_student_score
  end
end
