class ChangeBillingSchemeAttributes < ActiveRecord::Migration[5.2]
  def change
    rename_column :billing_scheme, :price_usd, :price_per_course
    remove_column :billing_scheme, :name

    add_column :payments, :billing_scheme_id, :integer
  end
end
