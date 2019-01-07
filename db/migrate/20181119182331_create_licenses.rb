class CreateLicenses < ActiveRecord::Migration[5.2]
  def change
    create_table :licenses do |t|
      t.belongs_to :user, index: true, foreign_key: true

      t.integer :license_type_id, null: false
      t.integer :max_courses
      t.integer :max_students
      t.datetime :expires, null: false

      t.timestamps
    end

    create_table :license_types do |t|
      t.string :name, null: false
      t.integer :default_max_courses
      t.integer :default_max_students
      t.integer :default_duration_months # Use interval instead?
      t.decimal :price_usd
      t.boolean :hide, null: false, default: false
    end

    create_table :payments do |t|
      t.belongs_to :license, index: true, foreign_key: true

      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :organization, null: false
      t.string :phone, null: false
      t.string :addr1, null: false
      t.string :addr2
      t.string :state
      t.string :zip
      t.string :country, null: false
      t.string :source, null: false
      t.string :confirmation
      t.decimal :amount_usd, null: false

      t.timestamps
    end

    add_column :courses, :license_id, :integer
    add_foreign_key :courses, :licenses

    add_foreign_key :licenses, :license_types
  end
end
