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

  def start!(payment, stripe_token)
    add_payment! payment, stripe_token
  end

  def renew!(payment, stripe_token, duration=nil)
    duration ||= license_type.default_duration_months.months
    self.expires = is_expired? ? (DateTime.now + duration) : (expires + duration)
    add_payment! payment, stripe_token
  end

  private

  def add_payment!(payment, stripe_token)
    payments.push payment
    charge = payment.charge_stripe stripe_token
    # Force save immediately to ensure that a failed save invalidates the charge.
    begin
      save!
    rescue => e
      charge.refund
      raise
    end
  end
end
