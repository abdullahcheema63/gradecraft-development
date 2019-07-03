class AddShowGuideToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :show_guide, :boolean, default: true
  end
end
