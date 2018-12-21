class License < ApplicationRecord
  # has_paper_trail
  has_many :courses
  has_many :payments, class_name: "Payment"
  belongs_to :user
  belongs_to :license_type

  validates :license_type, presence: true

  accepts_nested_attributes_for :payments
end
