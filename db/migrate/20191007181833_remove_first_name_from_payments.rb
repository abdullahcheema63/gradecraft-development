class RemoveFirstNameFromPayments < ActiveRecord::Migration[5.2]
  def change
    remove_column :payments, :first_name, :string
    remove_column :payments, :last_name, :string
    remove_column :payments, :organization, :string
    remove_column :payments, :phone, :string
    remove_column :payments, :addr1, :string
    remove_column :payments, :addr2, :string
    remove_column :payments, :city, :string
    remove_column :payments, :state, :string
    remove_column :payments, :zip, :string
    remove_column :payments, :country, :string
  end
end
