namespace :export_filepaths do
  desc "Changes any SubmissionsExport with local_file_path as exports/* to files/exports/*"
  task update_submissions_export_filepaths: :environment do

    fileName = "#{Rails.root}/files/SubmissionExportAudit.txt"
    submissionExportAudit = File.open(fileName, 'w')

    submission_exports = SubmissionsExport.all

    outdated_file_path_regexp = Regexp.new("files\/.*")

    updated_submissions_export_file_paths = []
    missing_submissions_export_files = []
    valid_export_count = 0

    submission_exports.each do |submissions_export|
      current_file_path = submissions_export.local_file_path
      if !(current_file_path =~ outdated_file_path_regexp)
        submissionExportAudit.puts("updating file path for submissions_export:\n #{submissions_export.insepct} \n")
        updated_submissions_export_file_paths.push(submissions_export.id)
        submissions_export.local_file_path = "files/#{current_file_path}"
        submissions_export.save
      end

      file_path = "#{Rails.root}/#{submissions_export.local_file_path}"
      if !File.file?(file_path)
        submissionExportAudit.puts("could not find file for submissions_export:\n #{submissions_export.inspect} \n")
        submissionExportAudit.puts("File path: #{file_path}")
        submissionExportAudit.puts("Corse of SE: #{submissions_export.course.id}")
        missing_submissions_export_files.push(submissions_export.id)
        submissions_export.destroy
      else
        valid_export_count = valid_export_count + 1
      end
    end
    submissionExportAudit.puts("Existing & valid submission exports: #{valid_export_count}")

    submissionExportAudit.puts("\nSubmissionsExport ids with updated filepaths: #{updated_submissions_export_file_paths}")

    if missing_submissions_export_files.any?
      submissionExportAudit.puts("\nSubmissionsExport ids with missing files: #{missing_submissions_export_files}")
    end
  end

  desc "Changes any CourseAnalyticsExport with local_file_path as exports/* to files/exports/*"
  task update_course_analytics_export_filepaths: :environment do
    fileName = "#{Rails.root}/files/CourseAnalyticsExportAudit.txt"
    courseAnalyticsExportAudit = File.open(fileName, 'w')

    course_analytics_exports = CourseAnalyticsExport.all

    outdated_file_path_regexp = Regexp.new("files\/.*")

    updated_course_analytics_export_file_paths = []
    missing_course_analytics_export_files = []

    course_analytics_exports.each do |course_analytics_export|
      current_file_path =  course_analytics_export.local_file_path
      if !(current_file_path =~ outdated_file_path_regexp)
        courseAnalyticsExportAudit.puts("updating file path for course_analytics_export: \n #{course_analytics_export.inspect} \n")
        updated_course_analytics_export_file_paths.push(course_analytics_export.id)
        course_analytics_export.local_file_path = "files/#{current_file_path}"
        course_analytics_export.save
      end

      file_path = "#{Rails.root}/#{course_analytics_export.local_file_path}"
      if !File.file?(file_path)
        courseAnalyticsExportAudit.puts("Could not find file for course_analytics_export: \n #{course_analytics_export.inspect}")
        courseAnalyticsExportAudit.puts("File path: #{file_path}")
        missing_course_analytics_export_files.push(course_analytics_export.id)
        course_analytics_export.destroy
      end
    end

    courseAnalyticsExportAudit.puts("\nCourseAnalyticsExports ids with updated filepaths: #{updated_course_analytics_export_file_paths}")

    if missing_course_analytics_export_files.any?
      courseAnalyticsExportAudit.puts("\nCourseAnalyticsExport ids with missing files: #{missing_course_analytics_export_files}")
    end
  end

  desc "Removes SubmissionFile objects if the file does not exist or is corrupted"
  task :remove_submissionFile_objects,  [:delete_submission_file, :number] => [:environment] do |t, args|

    fileName = "#{Rails.root}/files/RemovedSubmissionFiles.txt"
    submissionFileAudit = File.open(fileName, 'w')

    file_number = args[:number].nil? ? SubmissionFile.all.length : args[:number].to_i

    submissionFiles = SubmissionFile.first(file_number)

    submissionFiles.each do |sf|
      if !sf.file.present?
        submissionFileAudit.puts("====================DELETING SUBMISSION FILE====================")
        submissionFileAudit.puts("Deleting because: There is no file associated with the submissionFile id: #{sf.id}")
        submissionFileAudit.puts("Destroying submission files is marked as #{args[:delete_submission_file]}")
        submissionFileAudit.puts("Submission file id: #{sf.id} \n Submission id: #{sf.submission.id} \n Assignment id: #{sf.assignment.id} \n Course id: #{sf.submission.course.id}")
        submissionFileAudit.puts("\n\n\n\n")
        submissionFileAudit.puts("#{sf.inspect}")
        submissionFileAudit.puts("\n\n\n\n")
        if args[:delete_submission_file] == "true"
          sf_id = sf.id
          sf.destroy
          submissionFileAudit.puts("Submission file (id: #{sf_id}) has been deleted")
        end
        next
      end

      if sf.file.path.present?
        if !(File.file?(sf.file.path))
          submissionFileAudit.puts("====================DELETING SUBMISSION FILE====================")
          submissionFileAudit.puts("Deleting because: Could not find file at this location: #{sf.file.path} \n")
          submissionFileAudit.puts("Destroying submission files is marked as #{args[:delete_submission_file]}")
          submissionFileAudit.puts("Submission file id: #{sf.id} \n Submission id: #{sf.submission.id} \n Assignment id: #{sf.assignment.id} \n Course id: #{sf.submission.course.id}")
          submissionFileAudit.puts("\n\n\n\n")
          submissionFileAudit.puts("#{sf.inspect}")
          submissionFileAudit.puts("\n\n\n\n")
          if args[:delete_submission_file] == "true"
            sf_id = sf.id
            sf.destroy
            submissionFileAudit.puts("Submission file (id: #{sf_id}) has been deleted")
          end
          next
        end
      else
        submissionFileAudit.puts("====================DELETING SUBMISSION FILE====================")
        submissionFileAudit.puts("Deleting because: There was no path associated with the file for submissionFile id: #{sf.id}\n")
        submissionFileAudit.puts("Destroying submission files is marked as #{args[:delete_submission_file]}")
        submissionFileAudit.puts("Submission file id: #{sf.id} \n Submission id: #{sf.submission.id} \n Assignment id: #{sf.assignment.id} \n Course id: #{sf.submission.course.id}")
        submissionFileAudit.puts("\n\n\n\n")
        submissionFileAudit.puts("#{sf.inspect}")
        submissionFileAudit.puts("\n\n\n\n")
        if args[:delete_submission_file] == "true"
          sf_id = sf.id
          sf.destroy
          submissionFileAudit.puts("Submission file (id: #{sf_id}) has been deleted")
        end
        next
      end
      submissionFileAudit.puts("Submission File with id: #{sf.id} valid")
    end

    submissionFileAudit.close
  end

  desc "Removes challengeFile objects if the file does not exist or is corrupted"
  task :remove_challengeFile_objects,  [:delete_challenge_file, :number] => [:environment] do |t, args|

    fileName = "#{Rails.root}/files/RemovedChallengeFiles.txt"
    challengeFileAudit = File.open(fileName, 'w')

    file_number = args[:number].nil? ? ChallengeFile.all.length : args[:number].to_i
    challengeFiles = ChallengeFile.first(file_number)

    challengeFiles.each do |cf|
      if !cf.file.present?
        challengeFileAudit.puts("====================DELETING challenge FILE====================")
        challengeFileAudit.puts("Deleting because: There is no file associated with the challengeFile id: #{cf.id}")
        challengeFileAudit.puts("Destroying challenge files is marked as #{args[:delete_challenge_file]}")
        challengeFileAudit.puts("challenge file id: #{cf.id} \n challenge id: #{cf.challenge.id} \n Course id: #{cf.challenge.course.id}")
        challengeFileAudit.puts("\n\n\n\n")
        challengeFileAudit.puts("#{cf.inspect}")
        challengeFileAudit.puts("\n\n\n\n")
        if args[:delete_challenge_file] == "true"
          cf_id = cf.id
          cf.destroy
          challengeFileAudit.puts("challenge file (id: #{cf_id}) has been deleted")
        end
        next
      end

      if cf.file.path.present?
        if !(File.file?(cf.file.path))
          challengeFileAudit.puts("====================DELETING challenge FILE====================")
          challengeFileAudit.puts("Deleting because: Could not find file at this location: #{cf.file.path} \n")
          challengeFileAudit.puts("Destroying challenge files is marked as #{args[:delete_challenge_file]}")
          challengeFileAudit.puts("challenge file id: #{cf.id} \n challenge id: #{cf.challenge.id} \n Course id: #{cf.challenge.course.id}")
          challengeFileAudit.puts("\n\n\n\n")
          challengeFileAudit.puts("#{cf.inspect}")
          challengeFileAudit.puts("\n\n\n\n")
          if args[:delete_challenge_file] == "true"
            cf_id = cf.id
            cf.destroy
            challengeFileAudit.puts("challenge file (id: #{cf_id}) has been deleted")
          end
          next
        end
      else
        challengeFileAudit.puts("====================DELETING challenge FILE====================")
        challengeFileAudit.puts("Deleting because: There was no path associated with the file for challengeFile id: #{cf.id}\n")
        challengeFileAudit.puts("Destroying challenge files is marked as #{args[:delete_challenge_file]}")
        challengeFileAudit.puts("challenge file id: #{cf.id} \n challenge id: #{cf.challenge.id} \n Course id: #{cf.challenge.course.id}")
        challengeFileAudit.puts("\n\n\n\n")
        challengeFileAudit.puts("#{cf.inspect}")
        challengeFileAudit.puts("\n\n\n\n")
        if args[:delete_challenge_file] == "true"
          cf_id = cf.id
          cf.destroy
          challengeFileAudit.puts("challenge file (id: #{cf_id}) has been deleted")
        end
        next
      end
      challengeFileAudit.puts("challenge File with id: #{cf.id} valid")
    end

    challengeFileAudit.close
  end


  desc "Removes badgeFile objects if the file does not exist or is corrupted"
  task :remove_badgeFile_objects,  [:delete_badge_file, :number] => [:environment] do |t, args|

    fileName = "#{Rails.root}/files/RemovedbadgeFiles.txt"

    badgeFileAudit = File.open(fileName, 'w')

    file_number = args[:number].nil? ? BadgeFile.all.length : args[:number].to_i

    badgeFiles = BadgeFile.first(file_number)

    badgeFiles.each do |bf|
      if !bf.file.present?
        badgeFileAudit.puts("====================DELETING badge FILE====================")
        badgeFileAudit.puts("Deleting because: There is no file associated with the badgeFile id: #{bf.id}")
        badgeFileAudit.puts("Destroying badge files is marked as #{args[:delete_badge_file]}")
        badgeFileAudit.puts("badge file id: #{bf.id} \n badge id: #{bf.badge.id}  \n Course id: #{bf.badge.course.id}")
        badgeFileAudit.puts("\n\n\n\n")
        badgeFileAudit.puts("#{bf.inspect}")
        badgeFileAudit.puts("\n\n\n\n")
        if args[:delete_badge_file] == "true"
          bf_id = bf.id
          bf.destroy
          badgeFileAudit.puts("badge file (id: #{bf_id}) has been deleted")
        end
        next
      end

      if bf.file.path.present?
        if !(File.file?(bf.file.path))
          badgeFileAudit.puts("====================DELETING badge FILE====================")
          badgeFileAudit.puts("Deleting because: Could not find file at this location: #{bf.file.path} \n")
          badgeFileAudit.puts("Destroying badge files is marked as #{args[:delete_badge_file]}")
          badgeFileAudit.puts("badge file id: #{bf.id} \n badge id: #{bf.badge.id}  \n Course id: #{bf.badge.course.id}")
          badgeFileAudit.puts("\n\n\n\n")
          badgeFileAudit.puts("#{bf.inspect}")
          badgeFileAudit.puts("\n\n\n\n")
          if args[:delete_badge_file] == "true"
            bf_id = bf.id
            bf.destroy
            badgeFileAudit.puts("badge file (id: #{bf_id}) has been deleted")
          end
          next
        end
      else
        badgeFileAudit.puts("====================DELETING badge FILE====================")
        badgeFileAudit.puts("Deleting because: There was no path associated with the file for badgeFile id: #{bf.id}\n")
        badgeFileAudit.puts("Destroying badge files is marked as #{args[:delete_badge_file]}")
        badgeFileAudit.puts("badge file id: #{bf.id} \n badge id: #{bf.badge.id}  \n Course id: #{bf.badge.course.id}")
        badgeFileAudit.puts("\n\n\n\n")
        badgeFileAudit.puts("#{bf.inspect}")
        badgeFileAudit.puts("\n\n\n\n")
        if args[:delete_badge_file] == "true"
          bf_id = bf.id
          bf.destroy
          badgeFileAudit.puts("badge file (id: #{bf_id}) has been deleted")
        end
        next
      end
      badgeFileAudit.puts("badge File with id: #{bf.id} valid")
    end

    badgeFileAudit.close
  end

  desc "Removes assignmentFile objects if the file does not exist or is corrupted"
  task :remove_assignmentFile_objects,  [:delete_assignment_file, :number] => [:environment] do |t, args|

    fileName = "#{Rails.root}/files/RemovedassignmentFiles.txt"
    assignmentFileAudit = File.open(fileName, 'w')

    file_number = args[:number].nil? ? AssignmentFile.all.length : args[:number].to_i
    assignmentFiles = AssignmentFile.first(file_number)

    assignmentFiles.each do |af|
      if !af.file.present?
        assignmentFileAudit.puts("====================DELETING assignment FILE====================")
        assignmentFileAudit.puts("Deleting because: There is no file associated with the assignmentFile id: #{af.id}")
        assignmentFileAudit.puts("Destroying assignment files is marked as #{args[:delete_assignment_file]}")
        assignmentFileAudit.puts("assignment file id: #{af.id} \n assignment id: #{af.assignment.id} \n Assignment id: #{af.assignment.id} \n Course id: #{af.assignment.course.id}")
        assignmentFileAudit.puts("\n\n\n\n")
        assignmentFileAudit.puts("#{af.inspect}")
        assignmentFileAudit.puts("\n\n\n\n")
        if args[:delete_assignment_file] == "true"
          af_id = af.id
          af.destroy
          assignmentFileAudit.puts("assignment file (id: #{af_id}) has been deleted")
        end
        next
      end

      if af.file.path.present?
        if !(File.file?(af.file.path))
          assignmentFileAudit.puts("====================DELETING assignment FILE====================")
          assignmentFileAudit.puts("Deleting because: Could not find file at this location: #{af.file.path} \n")
          assignmentFileAudit.puts("Destroying assignment files is marked as #{args[:delete_assignment_file]}")
          assignmentFileAudit.puts("assignment file id: #{af.id} \n assignment id: #{af.assignment.id} \n Assignment id: #{af.assignment.id} \n Course id: #{af.assignment.course.id}")
          assignmentFileAudit.puts("\n\n\n\n")
          assignmentFileAudit.puts("#{af.inspect}")
          assignmentFileAudit.puts("\n\n\n\n")
          if args[:delete_assignment_file] == "true"
            af_id = af.id
            af.destroy
            assignmentFileAudit.puts("assignment file (id: #{af_id}) has been deleted")
          end
          next
        end
      else
        assignmentFileAudit.puts("====================DELETING assignment FILE====================")
        assignmentFileAudit.puts("Deleting because: There was no path associated with the file for assignmentFile id: #{af.id}\n")
        assignmentFileAudit.puts("Destroying assignment files is marked as #{args[:delete_assignment_file]}")
        assignmentFileAudit.puts("assignment file id: #{af.id} \n assignment id: #{af.assignment_id}} \n Course id: #{af.assignment.course.id}")
        assignmentFileAudit.puts("\n\n\n\n")
        assignmentFileAudit.puts("#{af.inspect}")
        assignmentFileAudit.puts("\n\n\n\n")
        if args[:delete_assignment_file] == "true"
          af_id = af.id
          af.destroy
          assignmentFileAudit.puts("assignment file (id: #{af_id}) has been deleted")
        end
        next
      end
      assignmentFileAudit.puts("assignment File with id: #{af.id} valid")
    end

    assignmentFileAudit.close
  end


  desc "Removes fileUpload objects if the file does not exist or is corrupted"
  task :remove_fileUpload_objects,  [:delete_file_upload_file, :number] => [:environment] do |t, args|

    fileName = "#{Rails.root}/files/RemovedfileUploads.txt"
    fileUploadAudit = File.open(fileName, 'w')

    file_number = args[:number].nil? ? FileUpload.all.length : args[:number].to_i
    fileUploads = FileUpload.first(file_number)

    fileUploads.each do |fu|
      if !fu.file.present?
        fileUploadAudit.puts("====================DELETING file upload FILE====================")
        fileUploadAudit.puts("Deleting because: There is no file associated with the fileUpload id: #{fu.id}")
        fileUploadAudit.puts("Destroying file upload files is marked as #{args[:delete_file_upload_file]}")
        if Grade.exists?(fu.grade_id)
          fileUploadAudit.puts("file upload file id: #{fu.id} \n Grade id: #{fu.grade_id} \n Assignment id: #{Grade.find(fu.grade_id).assignment.id} \n Course id: #{Grade.find(fu.grade_id).course.id}")
        else
          fileUploadAudit.puts("**could not find grade with id: #{fu.grade_id}")
        end
        fileUploadAudit.puts("\n\n\n\n")
        fileUploadAudit.puts("#{fu.inspect}")
        fileUploadAudit.puts("\n\n\n\n")
        if args[:delete_file_upload_file] == "true"
          fu_id = fu.id
          fu.destroy
          fileUploadAudit.puts("file upload file (id: #{fu_id}) has been deleted")
        end
        next
      end

      if fu.file.path.present?
        if !(File.file?(fu.file.path))
          fileUploadAudit.puts("====================DELETING file upload file====================")
          fileUploadAudit.puts("Deleting because: Could not find file at this location: #{fu.file.path} \n")
          fileUploadAudit.puts("Destroying file upload files is marked as #{args[:delete_file_upload_file]}")
          if Grade.exists?(fu.grade_id)
            fileUploadAudit.puts("file upload file id: #{fu.id} \n Grade id: #{fu.grade_id} \n Assignment id: #{Grade.find(fu.grade_id).assignment.id} \n Course id: #{Grade.find(fu.grade_id).course.id}")
          else
            fileUploadAudit.puts("**could not find grade with id: #{fu.grade_id}")
          end
          fileUploadAudit.puts("\n\n\n\n")
          fileUploadAudit.puts("#{fu.inspect}")
          fileUploadAudit.puts("\n\n\n\n")
          if args[:delete_file_upload_file] == "true"
            fu_id = fu.id
            fu.destroy
            fileUploadAudit.puts("file upload file (id: #{fu_id}) has been deleted")
          end
          next
        end
      else
        fileUploadAudit.puts("====================DELETING file upload file====================")
        fileUploadAudit.puts("Deleting because: There was no path associated with the file for fileUpload id: #{fu.id}\n")
        fileUploadAudit.puts("Destroying file upload files is marked as #{args[:delete_file_upload_file]}")
        if Grade.exists?(fu.grade_id)
          fileUploadAudit.puts("file upload file id: #{fu.id} \n Grade id: #{fu.grade_id} \n Assignment id: #{Grade.find(fu.grade_id).assignment.id} \n Course id: #{Grade.find(fu.grade_id).course.id}")
        else
          fileUploadAudit.puts("**could not find grade with id: #{fu.grade_id}")
        end
        fileUploadAudit.puts("\n\n\n\n")
        fileUploadAudit.puts("#{fu.inspect}")
        fileUploadAudit.puts("\n\n\n\n")
        if args[:delete_file_upload_file] == "true"
          fu_id = fu.id
          fu.destroy
          fileUploadAudit.puts("file upload file (id: #{fu_id}) has been deleted")
        end
        next
      end
      fileUploadAudit.puts("file upload file with id: #{fu.id} valid")
    end

    fileUploadAudit.close
  end
end
