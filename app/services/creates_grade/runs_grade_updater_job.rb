module Services
  module Actions
    class RunsGradeUpdaterJob
      extend LightService::Action

      expects :grade

      executed do |context|
        grade = context[:grade]
        GradeUpdaterJob.perform_async(grade.id) if grade.student_visible?
      end
    end
  end
end
