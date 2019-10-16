class Subscription < ApplicationRecord
  # before_create :set_defaults

  # has_paper_trail
  has_many :courses
  has_many :payments, class_name: "Payment"
  belongs_to :user
  # belongs_to :license_type
  # belongs_to :billing_scheme // price per course & tier level 1-5 etc...

  validates_presence_of :billing_scheme_id

  accepts_nested_attributes_for :payments

  def is_expired?
    renewal_date < DateTime.current if renewal_date
  end

  def create_charge(payment)
    #renewal date is being set to null if there subsription is just created?

    add_payment! payment
  end

  def start!(payment, duration=nil)
    # set duration as default for subscription?
    # Payment is calculated based on duration & pricing teir
    # billing scheme can return price per month
    # duration stores amount of months they pay for?
    duration ||= DateTime.now + 1.month
    self.renewal_date = duration
    add_payment! payment
  end

  def renew!(payment, duration=nil)
    # See notes from above `start!` method
    # duration ||= self.license_type.default_duration_months.months
    duration ||= DateTime.now + 1.month
    self.renewal_date = is_expired? ? (duration) : (renewal_date + 1.month)
    add_payment! payment
  end

  def update_billing_scheme_id(billing_scheme_id)
    self.update_attribute(:billing_scheme_id, billing_scheme_id)
  end

  def create_stripe_customer(email)
    customer = Stripe::Customer.create(
      email: email
    )
    self.customer_id = customer.id
    if self.save!
      puts "created stripe customer"
    else
      puts "error creating stripe customer"
      puts self.inspect
    end
  end

  def unsubscribe_courses(course_ids)
    course_ids.each do |id|
      course = Course.find(id)
      course.unsubscribe
    end
  end

  def subscribe_courses(course_ids)
    course_ids.each do |id|
      course = Course.find(id)
      course.subscribe(self.id)
    end
  end

  private

  def payment_note
    #self.license_type.name + " Exp.: " + self.expires.to_s
    "Subscription for " + self.courses.last.name + " exp.: " + self.renewal_date.to_s

  end

  def add_payment!(payment)
    intent = payment.charge_customer
    puts "\n\n\n intent: #{intent}"
    payment.payment_intent_id = intent.charges.data.first.id
    payment.save

    if intent.charges.data.first.status === "succeeded"
      puts "!!! Payment was a success !!!"
      if self.renewal_date.nil? || self.renewal_date < DateTime.current
        self.renewal_date = DateTime.current + 1.month
      else
        self.renewal_date = self.renewal_date + 1.month
      end
      save!
      NotificationMailer.payment_received(payment).deliver_now
    else
      puts "payment did not work ): "
    end

    # # Force save immediately to ensure that a failed save invalidates the charge.
    # begin
    #   save!
    #   NotificationMailer.payment_received(payment).deliver_now
    # rescue => e
    #   payment.refund!
    #   raise
    # end
  end
end
