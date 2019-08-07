namespace :export_filepaths do
  desc "Changes any SubmissionsExport with local_file_path as exports/* to files/exports/*"
  task update_submissions_export_filepaths: :environment do
    submission_exports = SubmissionsExport.all
    
    outdated_file_path_regexp = Regexp.new("files\/.*")

    updated_submissions_export_file_paths = []
    missing_submissions_export_files = []

    submission_exports.each do |submissions_export|     
      current_file_path = submissions_export.local_file_path
      if !(current_file_path =~ outdated_file_path_regexp)
        updated_submissions_export_file_paths.push(submissions_export.id)
        submissions_export.local_file_path = "files/#{current_file_path}"
      end

      if !File.file?("#{Rails.root}/#{submissions_export.local_file_path}")
        missing_submissions_export_files.push(submissions_export.id)
        submissions_export.destroy
      end
    end

    puts "\nChanged all SubmissionsExports with local_file_path set as exports/* to files/exports/*"
    puts "\nSubmissionsExport ids with updated filepaths: #{updated_submissions_export_file_paths}"

    if missing_submissions_export_files.any?
      puts "\nSubmissionsExport ids with missing files: #{missing_submissions_export_files}"
    end
  end

  desc "Changes any CourseAnalyticsExport with local_file_path as exports/* to files/exports/*"
  task update_course_analytics_export_filepaths: :environment do
    course_analytics_exports = CourseAnalyticsExport.all
    
    outdated_file_path_regexp = Regexp.new("files\/.*")

    updated_course_analytics_export_file_paths = []
    missing_course_analytics_export_files = []

    course_analytics_exports.each do |course_analytics_export|     
      current_file_path =  course_analytics_export.local_file_path
      if !(current_file_path =~ outdated_file_path_regexp)
        updated_course_analytics_export_file_paths.push(course_analytics_export.id)
        course_analytics_export.local_file_path = "files/#{current_file_path}"
      end

      if !File.file?("#{Rails.root}/#{course_analytics_export.local_file_path}")
        missing_course_analytics_export_files.push(course_analytics_export.id)
        course_analytics_export.destroy
      end
    end

    puts "\nChanged all CourseAnalyticsExports with local_file_path set as exports/* to files/exports/*"
    puts "\nCourseAnalyticsExports ids with updated filepaths: #{updated_course_analytics_export_file_paths}"

    if missing_course_analytics_export_files.any?
      puts "\nCourseAnalyticsExport ids with missing files: #{missing_course_analytics_export_files}"
    end
  end
end
