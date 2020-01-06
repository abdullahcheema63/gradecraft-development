class AddVisitsToPredictions < ActiveRecord::Migration[5.2]
  def change
    add_column :predicted_earned_badges , :ahoy_visit_id, :bigint

    add_column :predicted_earned_challenges , :ahoy_visit_id, :bigint

    add_column :predicted_earned_grades , :ahoy_visit_id, :bigint
  end
end
