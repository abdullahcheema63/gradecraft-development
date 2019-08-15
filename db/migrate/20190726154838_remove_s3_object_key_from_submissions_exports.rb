class RemoveS3ObjectKeyFromSubmissionsExports < ActiveRecord::Migration[5.2]
  def change
    remove_column :submissions_exports, :s3_bucket_name, :text
    remove_column :course_analytics_exports, :s3_bucket_name, :text
  end
end
