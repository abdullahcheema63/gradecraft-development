class RenameBillingSchemeTable < ActiveRecord::Migration[5.2]
  def change
    rename_table :billing_scheme, :billing_schemes
  end
end
