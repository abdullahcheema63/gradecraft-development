class Subscription < ApplicationRecord
  # before_create :set_defaults

  # has_paper_trail
  has_many :courses
  has_many :payments, class_name: "Payment"
  belongs_to :user
  belongs_to :billing_scheme

  validates_presence_of :billing_scheme_id # is this needed ??

  accepts_nested_attributes_for :payments

  def is_expired?
    return true
    #adding the return true so that the offline payment will always trigger
    renewal_date < DateTime.current if renewal_date
  end

  def failed_last_payment?
    payments.last.failed if payments.any?
  end

  def initiate_payment(payment)
    #Payment used for in-session payments between monthly cycle
    payment.charge_customer
  end

  def initiate_off_session_payment
    if renewal_date && self.is_expired? && courses.count
      self.update_billing_scheme # Should the billing scheme be updated here ??
      amount_to_pay = courses.count * self.billing_scheme.price_per_course
      payment = Payment.new({
        amount_usd: amount_to_pay,
        billing_scheme_id: self.billing_scheme_id,
        subscription_id: self.id
      })
      payment.course_ids = self.course_ids
      add_off_session_payment payment
    end
  end

  def renew!(payment, duration=nil)
    # See notes from above `start!` method
    # duration ||= self.license_type.default_duration_months.months
    duration ||= DateTime.now + 1.month
    self.renewal_date = is_expired? ? (duration) : (renewal_date + 1.month)
    add_payment! payment
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

  def update_billing_scheme
    courses_count = courses.count
    BillingScheme.all.each do |bs|
      if bs.min_courses <= courses_count && courses_count <= bs.max_courses
        if self.billing_scheme_id != bs.id
          self.update_attribute(:billing_scheme_id, bs.id)
        end
      end
    end
  end

  def extend_renewal_date
    self.update_attribute(:renewal_date, Date.current.at_beginning_of_month.next_month)
  end

  private

  def payment_note
    #self.license_type.name + " Exp.: " + self.expires.to_s
    "Subscription for " + self.user.last.name + " exp.: " + self.renewal_date.to_s

  end

  def add_off_session_payment(payment)
    begin
      intent = payment.charge_customer_off_session
    rescue Stripe::CardError => e
      puts "error error: #{e}"
      payment.status = e.error.code
      handle_payment_failure(e.error.message, payment)
    rescue Stripe::RateLimitError => e
      handle_payment_failure(e.error.message, payment)
      # Too many requests made to the API too quickly
    rescue Stripe::AuthenticationError => e
      handle_payment_failure(e.error.message, payment)
      # Authentication with Stripe's API failed
    rescue Stripe::APIConnectionError => e
      handle_payment_failure(e.error.message, payment)
      # Network communication with Stripe failed
    rescue Stripe::StripeError => e
      handle_payment_failure(e.error.message, payment)
      # Display a very generic error to the user, and maybe send
      # yourself an email
    rescue => e
      handle_payment_failure(e.error.message, payment)
      # Something else happened, completely unrelated to Stripe
    end

    if intent && intent.status === "succeeded"
      puts "!!! Payment was a success !!!"
      payment.status = "succeeded"
      payment.save
      self.extend_renewal_date
      NotificationMailer.monthly_payment_received(payment).deliver_now
    end
  end

  def handle_payment_failure(error, payment)
    puts "!~FAILED PAYMENT~! Error: #{error}"
    NotificationMailer.monthly_payment_failed(payment).deliver_now
    payment.update_attribute(:failed, true)
  end
end
