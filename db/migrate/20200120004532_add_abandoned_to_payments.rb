class AddAbandonedToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :abandoned, :boolean, default: false
  end
end
