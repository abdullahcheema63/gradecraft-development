class License < ApplicationRecord
  before_create :set_defaults

  # has_paper_trail
  has_many :courses
  has_many :payments, class_name: "Payment"
  belongs_to :user
  belongs_to :license_type

  validates_presence_of :license_type

  accepts_nested_attributes_for :payments

  def set_defaults
    self.max_courses ||= self.license_type.default_max_courses
    self.max_students ||= self.license_type.default_max_students
  end

  def is_expired?
    expires < DateTime.now
  end

  def start!(payment, duration=nil)
    duration ||= self.license_type.default_duration_months.months
    self.expires = DateTime.now + duration
    add_payment! payment
  end

  def renew!(payment, duration=nil)
    duration ||= self.license_type.default_duration_months.months
    self.expires = is_expired? ? (DateTime.now + duration) : (expires + duration)
    add_payment! payment
  end

  private

  def payment_note
    self.license_type.name + " Exp.: " + self.expires.to_s
  end

  def add_payment!(payment)
    payments.push payment
    charge = payment.charge! self.user.email, payment_note
    # Force save immediately to ensure that a failed save invalidates the charge.
    begin
      save!
      NotificationMailer.payment_received(payment).deliver_now
    rescue => e
      payment.refund!
      raise
    end
  end
end
