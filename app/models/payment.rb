class Payment < ApplicationRecord
  belongs_to :subscription

  has_and_belongs_to_many :courses

  attr_accessor :payment_method_id

  validates_presence_of :amount_usd

  scope :recently_paid_courses_count, -> {where("payments.created_at > ? ", 10.days.ago).where(status: "succeeded").joins(:courses).count}

  def charge_customer
    #Used for payments made between monthly subscription charges
    customer_id = self.subscription.customer_id
    customer = Stripe::Customer.retrieve(customer_id)

    payment_method_id = get_payment_method_id(customer)

    # ?? i don't think below is needed because the begin / rescue will catch this
      # return here if there are no payment_methods

    intent = create_payment_intent(customer_id)
    self.update_attribute(:payment_intent_id, intent.id)

    puts "inside payment #charge_customer, paymet: #{self.inspect}"

    confirm_payment_intent(payment_method_id)
  end

  def charge_customer_off_session
    customer_id = self.subscription.customer_id
    customer = Stripe::Customer.retrieve(customer_id)

    payment_method_id = get_payment_method_id(customer)
    #? return here if there are no payment_methods

    intent = create_payment_intent(customer_id)
    self.update_attribute(:payment_intent_id, intent.id)

    confirm_off_session_payment_intent(payment_method_id)
  end

  #~~~James Method ~~~
  def refund!
    return nil unless self.payment_intent_id == "Stripe" && self.confirmation
    charge = retrieve_stripe_charge(self.confirmation)
    charge.refund
  end

  def amount_cents
    (amount_usd * 100).to_i
  end

  def retrieve_stripe_payment_intent
    Stripe::PaymentIntent.retrieve(self.payment_intent_id)
  end

  private

  def get_payment_method_id(customer)
    payment_method_id = customer.invoice_settings.default_payment_method
    if !payment_method_id
      response = Stripe::PaymentMethod.list({customer: customer.id, type: 'card'})
      payment_methods = response.data

      payment_method_id = payment_methods.first
      #check this logic / method
    end
    return payment_method_id
  end

  def create_payment_intent(customer_id)
    Stripe::PaymentIntent.create({
      amount: amount_cents,
      customer: customer_id,
      currency: 'usd',
    })
  end

  #STRIPE has option for 'recipt_email' --> wondering what is in this email / if we want to use it
  def confirm_payment_intent(payment_method_id)
    Stripe::PaymentIntent.confirm( self.payment_intent_id,
      {
        off_session: false,
        payment_method: payment_method_id
      })
  end

  def confirm_off_session_payment_intent(payment_method_id)
    Stripe::PaymentIntent.confirm(
      self.payment_intent_id,
      {
        off_session: true,
        payment_method: payment_method_id
      })
  end

  def create_stripe_charge(customer_id, amount_cents, description)
    Stripe::Charge.create(
      customer: customer_id,
      amount: amount_cents,
      description: description,
      currency: "usd",
    )
  end

  def retrieve_stripe_charge(charge_id)
    Stripe::Charge.retrieve(charge_id)
  end
end
