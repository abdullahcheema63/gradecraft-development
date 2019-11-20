class AddVisitIdToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :ahoy_visit_id, :bigint
  end
end
