class ChangeSubscriptionsRenewalDateToNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null(:subscriptions, :renewal_date, true)
  end
end
