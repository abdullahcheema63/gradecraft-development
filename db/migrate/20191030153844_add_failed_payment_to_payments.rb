class AddFailedPaymentToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :failed, :boolean, default: false
    remove_column :payments, :charge_id, :string
    rename_column :payments, :confirmation, :status
  end
end
