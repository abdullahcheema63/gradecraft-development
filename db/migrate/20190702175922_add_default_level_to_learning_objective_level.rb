class AddDefaultLevelToLearningObjectiveLevel < ActiveRecord::Migration[5.2]
  def change
    add_column :learning_objective_levels, :default_level, :boolean
  end
end
