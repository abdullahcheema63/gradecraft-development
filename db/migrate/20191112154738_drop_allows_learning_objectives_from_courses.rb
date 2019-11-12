class DropAllowsLearningObjectivesFromCourses < ActiveRecord::Migration[5.2]
  def change
    remove_column :courses, :allows_learning_objectives, :boolean
  end
end
