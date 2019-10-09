class AddPaymentMethodIdToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :payment_method_id, :string
  end
end
