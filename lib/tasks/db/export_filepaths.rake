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

  desc "Removes SubmissionFile objects if the file does not exist or is corrupted"
  task remove_submissionFile_objects: :environment do
    fileName = "#{Rails.root}/files/RemovedSubmissionFiles.txt"

    submissionFileAudit = File.open(fileName, 'w')

    submissionFiles = SubmissionFile.all

    submissionFiles.each do |sf|
      if !sf.file.present?
        submissionFileAudit.puts("There is no file assocaited with the submissionFile id: #{sf.id}")
        sf.destroy
        next
      end

      if sf.file.path.present?
        if !(File.file?(sf.file.path))
          submissionFileAudit.puts("Could not find file at this location: #{sf.file.path} \n")
          sf.destroy
          next
        end
      else
        submissionFileAudit.puts("There was no path associated with the file for submissionFile id: #{sf.id}")
        sf.destroy
        next
      end

      submissionFileAudit.close
    end
  end

  desc "Removes challengeFile objects if the file does not exist or is corrupted"
  task remove_challengeFile_objects: :environment do
    fileName = "#{Rails.root}/files/RemovedChallengeFiles.txt"

    challengeFileAudit = File.open(fileName, 'w')

    challengeFiles = ChallengeFile.all

    challengeFiles.each do |cf|
      if !cf.file.present?
        challengeFileAudit.puts("There is no file assocaited with the challengeFile id: #{cf.id}")
        cf.destroy
        next
      end

      if cf.file.path.present?
        if !(File.file?(cf.file.path))
          challengeFileAudit.puts("Could not find file at this location: #{cf.file.path} \n")
          cf.destroy
          next
        end
      else
        challengeFileAudit.puts("There was no path associated with the file for challengeFile id: #{cf.id}")
        cf.destroy
        next
      end

      challengeFileAudit.close
    end
  end

  desc "Removes badgeFile objects if the file does not exist or is corrupted"
  task remove_badgeFile_objects: :environment do
    fileName = "#{Rails.root}/files/RemovedBadgeFiles.txt"

    badgeFileAudit = File.open(fileName, 'w')

    badgeFiles = BadgeFile.all

    badgeFiles.each do |bf|
      if !bf.file.present?
        badgeFileAudit.puts("There is no file assocaited with the badgeFile id: #{bf.id}")
        bf.destroy
        next
      end

      if bf.file.path.present?
        if !(File.file?(bf.file.path))
          badgeFileAudit.puts("Could not find file at this location: #{bf.file.path} \n")
          bf.destroy
          next
        end
      else
        badgeFileAudit.puts("There was no path associated with the file for badgeFile id: #{bf.id}")
        bf.destroy
        next
      end

      badgeFileAudit.close
    end
  end

  desc "Removes assignmentFile objects if the file does not exist or is corrupted"
  task remove_assignmentFile_objects: :environment do
    fileName = "#{Rails.root}/files/RemovedAssignmentFiles.txt"

    assignmentFileAudit = File.open(fileName, 'w')

    assignmentFiles = AssignmentFile.all

    assignmentFiles.each do |af|
      if !af.file.present?
        assignmentFileAudit.puts("There is no file assocaited with the assignmentFile id: #{af.id}")
        af.destroy
        next
      end

      if af.file.path.present?
        if !(File.file?(af.file.path))
          assignmentFileAudit.puts("Could not find file at this location: #{af.file.path} \n")
          af.destroy
          next
        end
      else
        assignmentFileAudit.puts("There was no path associated with the file for assignmentFile id: #{af.id}")
        af.destroy
        next
      end

      assignmentFileAudit.close
    end
  end

  desc "Removes FileUpload objects if the file does not exist or is corrupted"
  task remove_FileUpload_objects: :environment do
    fileName = "#{Rails.root}/files/RemovedFileUploads.txt"

    fileUploadAudit = File.open(fileName, 'w')

    FileUploads = FileUpload.all

    FileUploads.each do |fu|
      if !fu.file.present?
        fileUploadAudit.puts("There is no file assocaited with the FileUpload id: #{fu.id}")
        fu.destroy
        next
      end

      if fu.file.path.present?
        if !(File.file?(fu.file.path))
          fileUploadAudit.puts("Could not find file at this location: #{fu.file.path} \n")
          fu.destroy
          next
        end
      else
        fileUploadAudit.puts("There was no path associated with the file for FileUpload id: #{fu.id}")
        fu.destroy
        next
      end

      fileUploadAudit.close
    end
  end
end
