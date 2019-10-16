class RemoveSourceFromPayments < ActiveRecord::Migration[5.2]
  def change
    remove_column :payments, :source, :string
    rename_column :payments, :payment_method_id, :payment_intent_id
  end
end
