class AddCustomerIdToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :customer_id, :string
  end
end
