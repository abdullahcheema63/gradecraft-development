class AddAssignmentSubmittedNotificationToCourse < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :assignment_submitted_notification, :boolean
  end
end
