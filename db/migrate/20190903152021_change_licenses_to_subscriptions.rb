class ChangeLicensesToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    rename_table :licenses, :subscriptions

    rename_table :license_types, :billing_scheme

    rename_column :courses, :license_id, :subscription_id
    rename_column :payments, :license_id, :subscription_id

    rename_column :subscriptions, :license_type_id, :billing_scheme_id

    rename_column :subscriptions, :expires, :renewal_date

    rename_column :billing_scheme, :default_max_courses, :max_courses
    rename_column :billing_scheme, :default_max_students, :min_courses

    remove_column :billing_scheme, :default_duration_months
    remove_column :subscriptions, :max_students
    remove_column :subscriptions, :max_courses
  end
end
