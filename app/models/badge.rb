class Badge < ApplicationRecord
  include Copyable
  include UnlockableCondition
  include MultipleFileAttributes
  include Analytics::BadgeAnalytics
  require 'fileutils'

  acts_as_list scope: :course

  mount_uploader :icon, BadgeIconUploader

  has_many :earned_badges, dependent: :destroy
  has_many :predicted_earned_badges, dependent: :destroy

  belongs_to :course

  accepts_nested_attributes_for :earned_badges, allow_destroy: true, reject_if: proc { |a| a.points.blank? }

  multiple_files :badge_files
  has_many :badge_files, dependent: :destroy, inverse_of: :badge
  accepts_nested_attributes_for :badge_files

  validates_presence_of :course, :name
  validates_numericality_of :full_points, allow_nil: true, length: { maximum: 9 }
  validates_inclusion_of :visible, :can_earn_multiple_times, :visible_when_locked,
    :show_name_when_locked, :show_points_when_locked, :show_description_when_locked,
    in: [true, false], message: "must be true or false"

  scope :visible, -> { where(visible: true) }
  scope :ordered, -> { order("position ASC") }
  scope :earned_this_week, -> { includes(:earned_badges).where("earned_badges.updated_at > ?", 7.days.ago).references(:earned_badges) }

  def copy(attributes={}, lookup_store=nil)
    Badge.acts_as_list_no_update do
      ModelCopier.new(self, lookup_store).copy(
        attributes: attributes,
        options: {
          lookups: [:courses],
          overrides: [
            -> (copy) { copy_files copy }
          ]
        }
      )
    end
  end

  # Counting how many times a particular student has earned this badge
  def earned_badge_count_for_student(student)
    earned_badges.where(student_id: student.id, student_visible: true).count
  end

  # Can this badge be awarded to a student?
  # Must accound for invisible earned badges
  def available_for_student?(student)
    can_earn_multiple_times ||
    earned_badges.where(student_id: student.id).count < 1
  end

  private

  def file_attachment_is_valid?(attachment_file)
    !attachment_file.file.nil? && !attachment_file.file.path.nil? && File.file?(attachment_file.file.path)
  end

  # Copy files that are stored on S3 via Carrierwave
  def copy_files(copy)
    copy.save unless copy.persisted?
    if icon.present? 
      copy_icon(copy)
    end
     
    if badge_files.any? 
      copy_badge_files(copy)
    end
  end

  # Copy badge icon
  def copy_icon(copy)
    CopyCarrierwaveFile::CopyFileService.new(self, copy, :icon).set_file
    copy.save unless copy.persisted?
  end

  # Copy badge files
  def copy_badge_files(copy)
    copy.save unless copy.persisted?

    badge_files.each do |bf|
      if file_attachment_is_valid?(bf)
        badge_file = copy.badge_files.create filename: bf[:filename]
        CopyCarrierwaveFile::CopyFileService.new(bf, badge_file, :file).set_file
        badge_file.save unless badge_file.persisted?
      end
    end
  end
end
