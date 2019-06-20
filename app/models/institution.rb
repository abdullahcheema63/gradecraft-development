class Institution < ApplicationRecord
  has_many :courses
  has_many :providers, dependent: :destroy, as: :providee

  validates :name, presence: true, uniqueness: true

  accepts_nested_attributes_for :providers, reject_if: proc { |attr| attr[:consumer_key].blank? }

  scope :order_by_name, -> { order name: :asc }
end
