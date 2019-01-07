class License < ApplicationRecord
  # has_paper_trail
  has_many :courses
  has_many :payments, class_name: "Payment"
  belongs_to :user
  belongs_to :license_type

  validates :license_type, presence: true

  accepts_nested_attributes_for :payments

  def is_expired?
    expires < DateTime.now
  end

  def renew!(payment, stripe_token, duration=nil)
    duration ||= license_type.default_duration_months.months
    new_expiry = is_expired? ? (DateTime.now + duration) : (expires + duration)
    self.expires = new_expiry
    payments.push(payment)
    payment.charge_stripe(stripe_token)
  end
end
