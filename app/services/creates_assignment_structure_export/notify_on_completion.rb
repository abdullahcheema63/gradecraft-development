module Services
  module Actions
    class NotifyOnCompletion
      extend LightService::Action
      expects :course, :current_user, :has_images, :export_archive_path, :csv_file

      executed do |context|
        course = Course.find(context.course_id)
        user = User.find(context.user_id)

        if !context.has_images
          images_archive_path = nil
        else
          images_archive_path = context.export_archive_path
        end

        ExportsMailer.assignment_structure_export(course, user, context.csv_file, images_archive_path).deliver_now
      end
    end
  end
end
