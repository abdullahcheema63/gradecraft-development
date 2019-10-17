module Services
  module Actions
    class RecalculatesStudentScore
      extend LightService::Action

      expects :earned_badge

      executed do |context|
        if context.earned_badge.badge.full_points?
          ScoreRecalculatorJob.perform_async(context.earned_badge.student_id, context.earned_badge.course_id)
        end
      end
    end
  end
end
