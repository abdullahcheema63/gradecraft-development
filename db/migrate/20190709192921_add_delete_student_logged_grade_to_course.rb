class AddDeleteStudentLoggedGradeToCourse < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :delete_student_logged_grade, :boolean, default: true
  end
end
