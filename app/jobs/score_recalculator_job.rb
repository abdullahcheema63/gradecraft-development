class ScoreRecalculatorJob
  include Sidekiq::Worker
  sidekiq_options queue: 'high'

  def perform(student_id, course_id)
    if student_id && course_id
      student = User.find(student_id)
      student.update_course_score_and_level course_id
    end
  end
end
