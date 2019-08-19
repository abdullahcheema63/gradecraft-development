class AddExportDateRangeEnabledToCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :export_date_range_enabled, :boolean
  end
end
