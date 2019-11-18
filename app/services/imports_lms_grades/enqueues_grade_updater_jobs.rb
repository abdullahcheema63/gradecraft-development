require_relative "../../jobs/grade_updater_job"

module Services
  module Actions
    class EnqueuesGradeUpdaterJobs
      extend LightService::Action

      expects :grades_import_result

      executed do |context|
        result = context.grades_import_result

        result.successful.each do |grade|
          GradeUpdaterJob.perform_async(grade.id) if grade.student_visible?
        end unless result.nil?
      end
    end
  end
end
