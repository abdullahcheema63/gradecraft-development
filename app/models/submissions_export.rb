require "export"
require "formatter"

class SubmissionsExport < ApplicationRecord
  # treat this resource as if it's responsible for managing an object on our local efs
  # Note that if this record is an ActiveRecord::Base descendant then a
  # callback for :rebuild_file_path is added for on: :save
  #
  include FileManager::PathFinder

  # give this resource additional methods that aren't s3-specific but that
  # assist in the export process
  #
  include Export::Model

  belongs_to :course
  belongs_to :professor, class_name: "User", foreign_key: "professor_id"
  belongs_to :team
  belongs_to :assignment

  # secure tokens allow for one-click downloads of the file from an email
  has_many :secure_tokens, as: :target, dependent: :destroy

  validates :course_id, presence: true
  validates :assignment_id, presence: true


  def local_file_path_prefix
    "files/exports/courses/#{course_id}/assignments/#{assignment_id}/" \
      "#{object_key_date}/#{object_key_microseconds}"
  end

  def url_safe_filename
    Formatter::Filename.new("#{export_file_basename}.zip").filename
  end

  def copy_from_tmp_to_local
    begin
      local_file_dir_name = File.dirname(self.local_file_path)
      directory_path = "#{Rails.root}/#{local_file_dir_name}"
      FileUtils.mkdir_p(directory_path)

      source_file = "/tmp/#{self.export_file_basename}.zip"
      if File.file?(source_file)
        destination_path = ["#{Rails.root}", self.local_file_path]
        destination_path = destination_path.join "/"
        FileUtils.cp(source_file, destination_path)
      end
    rescue StandardError => error
      puts error
    end
  end

  # methods for building and formatting the archive filename
  def export_file_basename
    @export_file_basename ||= "#{archive_basename} - #{filename_timestamp}".gsub(/\s+/," ")
  end

  def archive_basename
    [formatted_assignment_name,
     formatted_team_name,
     group_suffix].compact.join(" - ").strip
  end

  def formatted_assignment_name
    @formatted_assignment_name ||= Formatter::Filename.titleize assignment.name
  end

  def formatted_team_name
    @team_name ||= Formatter::Filename.titleize(team.name) if team
  end

  def group_suffix
    "Group Submissions" if use_groups
  end
end
