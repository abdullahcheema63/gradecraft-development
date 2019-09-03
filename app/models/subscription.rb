class Subscription < ApplicationRecord
  before_create :set_defaults

  # has_paper_trail
  has_many :courses
  has_many :payments, class_name: "Payment"
  belongs_to :user
  # belongs_to :license_type
  # belongs_to :billing_scheme // price per course & tier level 1-5 etc...
  #

  validates_presence_of :billing_scheme

  accepts_nested_attributes_for :payments

  def set_defaults
    # Would we need to set defaults for a subscription?

    self.max_courses ||= self.license_type.default_max_courses
    self.max_students ||= self.license_type.default_max_students
  end

  def is_expired?
    expires < DateTime.now
  end

  def start!(payment, duration=nil)
    # set duration as default for subscription?
    # Payment is calculated based on duration & pricing teir
    # billing scheme can return price per month
    # duration stores amount of months they pay for?
    duration ||= self.license_type.default_duration_months.months
    self.expires = DateTime.now + duration
    add_payment! payment
  end

  def renew!(payment, duration=nil)
    # See notes from above start! method
    duration ||= self.license_type.default_duration_months.months
    self.expires = is_expired? ? (DateTime.now + duration) : (expires + duration)
    add_payment! payment
  end

  private

  def payment_note
    #self.license_type.name + " Exp.: " + self.expires.to_s
    "Subscription for " + self.course.name + " exp.: " + self.expires.to_s

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
