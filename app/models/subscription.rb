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
    renewal_date < DateTime.current if renewal_date
  end

  def create_charge(payment)
    #renewal date is being set to nil if there subsription is just created?

    add_payment! payment
  end

  def start!(payment, duration=nil)
    # set duration as default for subscription?
    # Payment is calculated based on duration & pricing teir
    # billing scheme can return price per month

    add_payment! payment
  end

  def create_off_session_charge(payment)
    #determine amount to be paied here !
    #determine courses that are being paid for here
    if renewal_date && renewal_date.is_expired? && courses.count
      billing_scheme = determine_billing_scheme(courses.count)
      self.billing_scheme_id = billing_scheme.id # this should be done before / automatically
      amount_to_pay = courses.count * billing_scheme.price_per_course
      payment = Payment.new({
        amount_usd: amount_to_pay,
        billing_scheme_id: self.billing_scheme_id,
        subscription_id: self.id
      })
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

  def determine_billing_scheme(course_count)
    BillingScheme.all.each do |billing_scheme|
      if billing_scheme.min_courses <= course_count && course_count <= billing_scheme.max_courses
        return billing_scheme
      end
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

  def add_off_session_payment(payment)
    intent = payment.charge_customer_off_session
    puts "\n\n\n intent: #{intent}"
    payment.payment_intent_id = intent.charges.data.first.id
    #Revisit what `intent.charges.data.first.id` is, might want to make a second column for this in the db
      # so that if a payment fails, the failed intent ID is stored and can be resumed on-session
      # ? intent.charges.data.first.id --> save to a column `payment_charge_id`
    payment.save

    # set renewal date to be to the first of the next month
    # create failure path, and save payment intent ID to the payment so the user can start from the last payment
    


  end
end
