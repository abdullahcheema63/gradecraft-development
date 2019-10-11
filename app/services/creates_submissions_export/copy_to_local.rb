module Services
  module Actions
    class CopyToLocal
      extend LightService::Action
      expects :submissions_export

      executed do |context|
        submissions_export = context.submissions_export
        submissions_export.copy_from_tmp_to_local
      end
    end
  end
end
