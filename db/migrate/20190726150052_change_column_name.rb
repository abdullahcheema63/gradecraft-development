class ChangeColumnName < ActiveRecord::Migration[5.2]
  def change
    rename_column :submissions_exports, :s3_object_key, :local_file_path
    rename_column :course_analytics_exports, :s3_object_key, :local_file_path
  end
end
