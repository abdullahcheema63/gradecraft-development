namespace :grade_files do

  desc "Add grade file association for many to many relationship"
  task add_associations: :environment do
    FileAttachment.find_each(batch_size: 500) do |gf|
      if GradeFile.where(file_attachment_id: gf.id, grade_id: gf.grade_id).empty?
        GradeFile.create(file_attachment_id: gf.id, grade_id: gf.grade_id)
      end
    end
  end
end
