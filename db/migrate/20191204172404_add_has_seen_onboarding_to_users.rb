class AddHasSeenOnboardingToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :has_seen_onboarding, :boolean, default: false
  end
end
