class AddExportDateRangeDaysToCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :export_date_range_days, :integer, default: 90
  end
end
