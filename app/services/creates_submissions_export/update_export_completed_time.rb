module Services
  module Actions
    class UpdateExportCompletedTime
      extend LightService::Action
      expects :submissions_export

      executed do |context|
        context.submissions_export.update_export_completed_time
      end
    end
  end
end
