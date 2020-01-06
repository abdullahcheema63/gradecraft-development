require "sidekiq-scheduler"
require_relative "../jobs/score_recalculator_job"

class RecalculateRecentlyUpdatedScoresJob
  include Sidekiq::Worker

  LAST_UPDATED_RANGE = 24.hours.ago..Time.now

  def perform
    # call recalculate once per unique student_id, course_id combination
    teams_student_and_course = []
    updated_challenge_grades.each do |challenge_grade|
      if challenge_grade.team.students.count
        challenge_grade.team.students.ids.each do |student_id|
          teams_student_and_course << [ student_id, challenge_grade.team.course.id ]
        end
      end
    end

    unique_grades = (updated_grades.pluck(:student_id, :course_id) + updated_earned_badges.pluck(:student_id, :course_id) + teams_student_and_course).uniq
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
