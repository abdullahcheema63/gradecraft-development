class AddCourseIdToAhoyMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :ahoy_messages, :course_id, :integer
  end
end
