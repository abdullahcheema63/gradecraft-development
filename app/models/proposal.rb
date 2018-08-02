class Proposal < ApplicationRecord
  belongs_to :group

  scope :order_by_creation_date, -> { order("created_at ASC") }
end
