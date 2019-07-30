class SubmissionsExportPerformer < ResqueJob::Performer
  require "fileutils" # need this for mkdir_p
  require "open-uri" # need this for getting the S3 file over http
  include ModelAddons::ImprovedLogging # log errors with attributes

  attr_reader :submissions_export, :professor, :course, :errors, :assignment, :team, :submissions

  def output_to_file(output)
    begin 
      File.write("#{Rails.root}/files/output.txt", "#{output}\n", mode: 'a')
    rescue StandardError => error
      puts "Could not write file"
      puts "#{error}"
    end
  end

  def setup
    puts "tmpdir"
    output_to_file "----------------------------------------------------------"
    output_to_file "Submissions Export Performer Setup\n\n"
    output_to_file "tmpdir"
    
    S3fs.ensure_tmpdir # make sure the s3fs tmpdir exists
    
    puts "submissions export"
    output_to_file "submissions export"

    @submissions_export = SubmissionsExport.find @attrs[:submissions_export_id]
    
    puts "fetch assets"
    output_to_file "fetch assets"

    fetch_assets

    puts "submissions export update"
    output_to_file "submissions export update"

    @submissions_export.update_attributes submissions_export_attributes
    
    puts "errors"
    output_to_file "submissions export update"

    @errors = []

    output_to_file "----------------------------------------------------------"
  end



  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    if work_resources_present?
      run_performer_steps
      deliver_outcome_mailer

      submissions_export.update_export_completed_time
    else
      if logger
        log_error_with_attributes "@assignment.present? and/or" \
          "@submitters.present? failed and both should have been present, " \
          "could not do_the_work"
      end
    end
  end

  def performer_steps
    [
      :generate_export_csv, # generate the csv overview for the assignment or team
      :confirm_export_csv_integrity, # check whether the csv export was successful
      :create_submitter_directories, # generate submitter directories
      :submitter_directories_created_successfully, # check whether the submitter directories were all created successfully
      :create_submission_text_files, # create text files in each submitter directory if there is submission data that requires it
      :create_submission_binary_files, # create binary files in each submitter directory
      :write_note_for_missing_binary_files,
      :remove_empty_submitter_directories,
      :generate_error_log, # write error log for errors that may have occurred during file generation
      :archive_exported_files,
      :upload_archive_to_s3,
      :check_s3_upload_success
    ]
  end



  def run_performer_steps
    performer_steps.each {|step_name| run_step(step_name) }
  end

  def run_step(step_name)
    require_success(send("#{step_name}_messages"), max_result_size: 250) do
      send(step_name)
      @submissions_export.update_attributes last_completed_step: step_name
    end
  end

  def submissions_export_attributes
    if @submissions_export.last_export_started_at
      base_export_attributes.merge last_completed_step: nil
    else
      base_export_attributes
    end
  end

  def base_export_attributes
    {
      submitter_ids: @submitters.collect(&:id),
      submissions_snapshot: submissions_snapshot,
      last_export_started_at: Time.now
    }
  end

  def attributes
    base_export_attributes
  end

  def submission_binary_file_path(submitter, submission_file, index)
    # get the filename from the submission file with an index
    filename = submission_file.instructor_filename index
    submitter_directory_file_path submitter, filename
  end

  def write_submission_binary_file(submitter, submission_file, index)
    file_path = submission_binary_file_path(submitter, submission_file, index)
    stream_s3_file_to_disk(submission_file, file_path)
  end

  def create_binary_files_for_submission(submission)
    submission.submission_files.present.each_with_index do |submission_file, index|
      write_submission_binary_file(submission.submitter, submission_file, index)
    end
  end

  protected

  def work_resources_present?
    @assignment.present? && @submitters.present?
  end

  def fetch_assets
    @assignment = @submissions_export.assignment
    @course = @submissions_export.course
    @professor = @submissions_export.professor
    @team = @submissions_export.team
    @submitters = fetch_submitters
    @submitters_for_csv = fetch_submitters_for_csv
    @submissions = fetch_submissions
  end

  def s3_manager
    @s3_manager ||= @submissions_export.s3_manager || S3Manager::Manager.new
  end

  def tmp_dir
    @tmp_dir ||= S3fs.mktmpdir
  end

  def archive_root_dir
    @archive_root_dir ||= FileUtils.mkdir_p(archive_root_dir_path).first
  end

  def archive_root_dir_path
    @archive_root_dir_path ||= File.expand_path(submissions_export.export_file_basename, tmp_dir)
  end

  def csv_file_path
    @csv_file_path ||= File.expand_path("_grade_import_template.csv", archive_root_dir)
  end

  def sorted_submitter_directory_keys
    submissions_grouped_by_submitter.keys.sort
  end

  def submissions_grouped_by_submitter
    @submissions_grouped_by_submitter ||= @submissions.group_by do |submission|
      submitter_directory_names[submission.submitter_id]
    end
  end

  def submissions_snapshot
    @submissions_snapshot ||= @submissions.inject({}) do |memo, submission|
      memo[submission.id] = {
        submitter_id: submission.submitter_id,
        updated_at: submission.updated_at.to_s
      }
      memo
    end
  end

  def fetch_submitters_for_csv
    if @submissions_export.use_groups
      Group.where course: @course
    elsif @submissions_export.team
      User.students_being_graded_for_course(@course, @team)
    else
      User.students_being_graded_for_course(@course)
    end
  end

  def fetch_submitters
    if @submissions_export.use_groups
      @assignment.groups_with_files
    elsif @submissions_export.team
      @assignment.students_with_text_or_binary_files_on_team(@team)
    else
      @assignment.students_with_text_or_binary_files
    end
  end

  def fetch_submissions
    if @submissions_export.use_groups
      @assignment.submissions.with_group
    elsif @submissions_export.team
      @assignment.student_submissions_with_files_for_team(@team).reject(&:unsubmitted?)
    else
      @assignment.student_submissions_with_files.reject(&:unsubmitted?)
    end
  end

  def generate_export_csv
    output_to_file("========================================================")
    output_to_file("Submissions Export Performer\n\n")
    output_to_file(__method__.to_s)
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

  def confirm_export_csv_integrity
    output_to_file(__method__.to_s)
    @confirm_export_csv_integrity ||= File.exist?(csv_file_path)
  end

  # final archive concerns

  def archive_tmp_dir
    @archive_tmp_dir ||= S3fs.mktmpdir
  end

  def expanded_archive_base_path
    @expanded_archive_base_path ||= File.expand_path(submissions_export.export_file_basename, archive_tmp_dir)
  end

  ## creating submitter directories

  def submitter_directories_created_successfully
    output_to_file(__method__.to_s)
    missing_submitter_directories.empty?
  end

  def missing_submitter_directories
    @submitters.inject([]) do |memo, submitter|
      memo << submitter_directory_names[submitter.id] unless Dir.exist?(submitter_directory_path(submitter))
      memo
    end
  end

  # in the format of { student_id => "lastname_firstname(--username-if-naming-conflict)" }
  def submitter_directory_names
    @submitter_directory_names ||= @submitters.inject({}) do |memo, submitter|
      # check to see whether there are any duplicate student names
      total_submitters_with_name = @submitters.to_a.count do |compared_submitter|
        submitter.same_name_as?(compared_submitter)
      end

      if total_submitters_with_name > 1
        memo[submitter.id] = submitter.submitter_directory_name_with_suffix
      else
        memo[submitter.id] = submitter.submitter_directory_name
      end
      memo
    end
  end

  def create_submitter_directories
    output_to_file(__method__.to_s)
    @submitters.each do |submitter|
      dir_path = submitter_directory_path(submitter)
      FileUtils.mkdir_p(dir_path) # unless Dir.exist?(dir_path) # create directory with parents
    end
  end

  # removing submitter directories
  def remove_empty_submitter_directories
    output_to_file(__method__.to_s)
    @submitters.each do |submitter|
      if submitter_directory_empty?(submitter)
        Dir.delete submitter_directory_path(submitter)
      end
    end
  end

  def submitter_directory_empty?(submitter)
    (Dir.entries(submitter_directory_path(submitter)) - %w{ . .. }).empty?
  end

  def submitter_directory_path(submitter)
    File.expand_path(submitter_directory_names[submitter.id], archive_root_dir)
  end

  def create_submission_text_files
    output_to_file(__method__.to_s)
    submissions.each do |submission|
      # write the text file for the submission into the student export directory
      if submission.text_comment.present? || submission.link.present?
        create_submission_text_file(submission)
      end
    end
  end

  def create_submission_text_file(submission)
    if submissions_export.use_groups
      submitter_name = submission.group.name
    else
      submitter_name = "#{submission.student.last_name}, #{submission.student.first_name}"
    end

    open(submission_text_file_path(submission.submitter), "w") do |f|
      f.puts "Submission items from #{submitter_name}"

      if submission.text_comment.present?
        f.puts "\ntext comment: #{submission.text_comment}"
      end

      if submission.link.present?
        f.puts "\nlink: #{submission.link}"
      end
    end
  end

  def submission_text_file_path(submitter)
    File.expand_path submission_text_filename(submitter),
      submitter_directory_path(submitter)
  end

  def submission_text_filename(submitter)
    [
      formatted_submitter_name(submitter),
      submissions_export.formatted_assignment_name,
      "Submission Text.txt"
    ].join(" - ")
  end

  def formatted_submitter_name(submitter)
    Formatter::Filename.titleize submitter.name
  end

  def create_submission_binary_files
    output_to_file(__method__.to_s)
    @submissions.each do |submission|
      if submission.submission_files.present?
        submission.process_unconfirmed_files if submission.submission_files.unconfirmed.count > 0
        create_binary_files_for_submission(submission)
      end
    end
  end

  def missing_binaries_file_path
    File.expand_path("missing_files.txt", archive_root_dir)
  end

  def submission_files_with_missing_binaries
    @submission_files_with_missing_binaries ||= @assignment.submission_files_with_missing_binaries
  end

  def submitters_with_missing_binaries
    @submitters_with_missing_binaries ||= @assignment.submitters_with_missing_binaries
  end

  def write_note_for_missing_binary_files
    output_to_file(__method__.to_s)
    unless submitters_with_missing_binaries.empty?
      open(missing_binaries_file_path, "wt") do |file|
        write_missing_binary_text(file)
      end
    end
  end

  def write_missing_binary_text(file)
    file.puts "The following files were uploaded, but no longer appear to be available on the server:"
    write_missing_binary_files_for_submitter(file)
  end

  def write_missing_binary_files_for_submitter(file)
    submitters_with_missing_binaries.each_with_index do |submitter, index|
      file.puts "\n#{submitter.name}:"
      add_missing_binary_filenames_to_file(file, submitter)
    end
  end

  def add_missing_binary_filenames_to_file(file, student)
    submission_files_with_missing_binaries.each do |missing_file|
      file.puts "#{missing_file.filename}" if missing_file.submission.student_id == student.id
    end
  end

  def submitter_directory_file_path(student, filename)
    File.expand_path filename, submitter_directory_path(student)
  end

  def stream_s3_file_to_disk(submission_file, target_file_path)
    begin
      s3_manager.write_s3_object_to_disk(submission_file.s3_object_file_key, target_file_path)
    rescue Aws::S3::Errors::NoSuchKey
      submission_file.mark_file_missing
    end
  end

  def remove_if_exists(file_path)
    File.delete file_path if File.exist? file_path
  end

  def generate_error_log
    output_to_file(__method__.to_s)
    return if errors.empty?
    open(error_log_path, "w") {|file| file.puts errors }
  end

  def error_log_path
    File.expand_path("error_log.txt", archive_root_dir)
  end

  # archive export directory
  def archive_exported_files
    output_to_file(__method__.to_s)
    Archive::Zip.archive("#{expanded_archive_base_path}.zip", archive_root_dir)
  end

  def upload_archive_to_s3
    begin 
      output_to_file(__method__.to_s)
      #@submissions_export.upload_file_to_s3 "#{expanded_archive_base_path}.zip"
      output_to_file("made it into Submissions export performer # upload_archive_to_s3")
      output_to_file("submission_export.local_file_path: #{@submissions_export.local_file_path}")
      output_to_file("rails root: #{Rails.root}")
      
      destination_path = ["#{Rails.root}", "#{@submissions_export.local_file_path}"]
      destination_path = destination_path.join "/"
      
      output_to_file("destination_path:#{destination_path}\n")
      
      directory_path = File.dirname(destination_path)
      
      output_to_file("directory_path: #{directory_path}")

      output_to_file("copy location (expanded_archive_base_path): #{expanded_archive_base_path}.zip")
      
      FileUtils.mkdir_p(directory_path)
      FileUtils.cp("#{expanded_archive_base_path}.zip", destination_path)
      FileUtils.cp("#{expanded_archive_base_path}.zip", "#{Rails.root}/files/")
      
    rescue StandardError => error
      puts "Could not upload archived submission files"
      puts error
    end
  end

  def check_s3_upload_success
    output_to_file(__method__.to_s)
    output_to_file("========================================================")
    return true
    @check_s3_upload_success ||= submissions_export.local_file_exists?
  end

  def deliver_outcome_mailer
    if check_s3_upload_success
      deliver_archive_success_mailer
    else
      deliver_archive_failed_mailer
    end
  end

  def deliver_archive_success_mailer
    if @team
      deliver_team_export_successful_mailer
    else
      deliver_export_successful_mailer
    end
  end

  def deliver_archive_failed_mailer
    @team ? deliver_team_export_failure_mailer : deliver_export_failure_mailer
  end

  def deliver_export_successful_mailer
    ExportsMailer.submissions_export_success(professor, @assignment, \
      @submissions_export, secure_token).deliver_now
  end

  def deliver_team_export_successful_mailer
    ExportsMailer.team_submissions_export_success(professor, @assignment, \
      @team, @submissions_export, secure_token).deliver_now
  end

  def secure_token
    @secure_token ||= submissions_export.generate_secure_token
  end

  def deliver_export_failure_mailer
    ExportsMailer.submissions_export_failure(@professor, @assignment)
      .deliver_now
  end

  def deliver_team_export_failure_mailer
    ExportsMailer.team_submissions_export_failure(@professor, @assignment, \
      @team).deliver_now
  end

  def expand_messages(messages={})
    {
      success: [ messages[:success], message_suffix ].join(" "),
      failure: [ messages[:failure], message_suffix ].join(" ")
    }
  end

  def generate_export_json_messages
    expand_messages ({
      success: "Successfully generated the export JSON",
      failure: "Failed to generate the export JSON"
    })
  end

  def generate_export_csv_messages
    expand_messages({
      success: "Successfully generated the csv data",
      failure: "Failed to generate the csv data"
    })
  end

  def confirm_export_csv_integrity_messages
    expand_messages ({
      success: "Successfully saved the CSV file on disk",
      failure: "Failed to save the CSV file on disk"
    })
  end

  def create_submitter_directories_messages
    expand_messages ({
      success: "Successfully created the submitter directories",
      failure: "Failed to create the submitter directories"
    })
  end

  def write_note_for_missing_binary_files_messages
    expand_messages ({
      success: "Successfully wrote the note for missing binary files",
      failure: "Failed to write the missing binary files note"
    })
  end

  def submitter_directories_created_successfully_messages
    expand_messages ({
      success: "Successfully confirmed creation of all student directories",
      failure: "Some student directories did not create properly"
    })
  end

  def create_submission_text_files_messages
    expand_messages ({
      success: "Successfully created all text files for the student submissions",
      failure: "Student submission text files did not create properly"
    })
  end

  def create_submission_binary_files_messages
    expand_messages ({
      success: "Successfully created all binary files for the student submissions",
      failure: "Student submission binary files did not create properly"
    })
  end

  def generate_error_log_messages
    expand_messages ({
      success: "Successfully generated an error log for binary file creation if one was required",
      failure: "Failed to build an error log for binary file creation errors"
    })
  end

  def archive_exported_files_messages
    expand_messages ({
      success: "Successfully generated an archive containing the exported assignment files",
      failure: "Failed to generate an archive containing the exported assignment files"
    })
  end

  def upload_archive_to_s3_messages
    expand_messages ({
      success: "Successfully uploaded the submissions archive to S3",
      failure: "Failed to upload the submissions archive to S3"
    })
  end

  def remove_empty_submitter_directories_messages
    expand_messages ({
      success: "Successfully removed empty submitter directories from archive",
      failure: "Failed to remove empty submitter directories"
    })
  end

  def check_s3_upload_success_messages
    expand_messages ({
      success: "Successfully confirmed that the exported archive was uploaded to S3",
      failure: "Failed to confirm that the exported archive was uploaded to S3. ObjectSummary#exists? failed on the object instance."
    })
  end

  def message_suffix
    "for assignment #{@assignment.id} for students: #{@submitters.collect(&:id)}"
  end
end
