class AddDisableGradeEmailsToCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :disable_grade_emails, :boolean, default: false 
  end
end
