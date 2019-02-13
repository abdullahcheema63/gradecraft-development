class AddAchievedToLearningObjectiveCumulativeOutcome < ActiveRecord::Migration[5.2]
  def change
    add_column :learning_objective_cumulative_outcomes, :achieved, :boolean, nil: false, default: false
  end
end
