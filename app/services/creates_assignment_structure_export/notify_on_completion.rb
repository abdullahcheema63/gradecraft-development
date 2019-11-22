module Services
  module Actions
    class NotifyOnCompletion
      extend LightService::Action
      expects :course_id, :user_id, :csv_file

      executed do |context|
        course = Course.find(context.course_id)
        user = User.find(context.user_id)
        ExportsMailer.mail_assignment_structure_export(course, user, context.csv_file).deliver_now
    end
  end
end
