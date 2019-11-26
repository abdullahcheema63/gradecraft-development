module Services
  module Actions
    class NotifyOnCompletion
      extend LightService::Action
      expects :has_images, :csv_file

      executed do |context|
        images_archive = open(context.export_archive_path).read if context.has_images

        csv_data = open(context.csv_file).read
        
        ExportsMailer.assignment_structure_export(context.course, context.current_user, csv_data, images_archive).deliver_now
      end
    end
  end
end
