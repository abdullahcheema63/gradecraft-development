class ChallengeFile < ApplicationRecord

  belongs_to :challenge, inverse_of: :challenge_files

  validates :filename, presence: true, length: { maximum: 50 }

  mount_uploader :file, AttachmentUploader

  def course
    challenge.course
  end
end
