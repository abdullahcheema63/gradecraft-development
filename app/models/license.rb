class License < ApplicationRecord
  # has_paper_trail
  enum type: [ :legacy, :higher_ed_1, :higher_ed_2, :k12, :custom ]
  attr_accessor :first_name, :last_name, :organization, :type
  validates :first_name, :last_name, :organization, presence: true
  validates :type, inclusion: { in: types.keys }
end
