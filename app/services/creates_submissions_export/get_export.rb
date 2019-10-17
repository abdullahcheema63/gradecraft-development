module Services
  module Actions
    class GetExport
      extend LightService::Action
      expects :export_id
      promises :submissions_export

      executed do |context|
        context.submissions_export = SubmissionsExport.find(context.export_id)
      end
    end
  end
end
