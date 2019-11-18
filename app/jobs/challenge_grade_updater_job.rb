class ChallengeGradeUpdaterJob
  include Sidekiq::Worker

  def perform(challenge_grade_id)
    challenge_grade = ChallengeGrade.includes(:challenge, [team: :students]).find(challenge_grade_id)

    challenge_grade.cache_team_scores
    notify_challenge_grade_released(challenge_grade)
  end

  private

  def notify_challenge_grade_released(challenge_grade)
    challenge_grade.team.students.each do |student|
      if student.email_challenge_grade_notifications? challenge_grade.challenge.course
        NotificationMailer.challenge_grade_released(challenge_grade).deliver_now
      end
    end
  end
end
