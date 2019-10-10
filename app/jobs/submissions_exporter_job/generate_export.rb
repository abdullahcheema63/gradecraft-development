require "fileutils" # need this for mkdir_p

module SubmissionsExporterJob::GenerateExport
  def write_csv
    open(csv_file_path, "w") do |f|
      if submissions_export.use_groups
        export_data = GradeExporter.new
          .export_group_grades(@assignment, @submitters_for_csv)
        f.puts export_data
      else
        f.puts @assignment.grade_import(@submitters_for_csv)
      end
    end
  end

  private

  def csv_file_path
    @csv_file_path ||= File.expand_path("_grade_import_template.csv", archive_root_dir)
  end

  def archive_root_dir
    @archive_root_dir ||= FileUtils.mkdir_p(archive_root_dir_path).first
  end

  def archive_root_dir_path
    @archive_root_dir_path ||= File.expand_path(submissions_export.export_file_basename, tmp_dir)
  end

  def tmp_dir
    @tmp_dir ||= FileManager.make_temp_directories
  end
end
