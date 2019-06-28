class AddAssignmentRevisedNotificationToCourse < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :assignment_revised_notification, :boolean
  end
end
