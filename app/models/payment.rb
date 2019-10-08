class Payment < ApplicationRecord
  before_create :set_defaults

  belongs_to :subscription

  has_and_belongs_to_many :courses

  attr_accessor :stripe_token

  validates_presence_of :amount_usd

  def set_defaults
    self.source ||= self.stripe_token ? "Stripe" : nil
  end

  def charge_customer
    customer_id = self.subscription.customer_id
    intent = create_payment_intent(customer_id)

    

  end

  def charge!(email, description)
    return nil unless self.stripe_token
    customer = create_stripe_customer(email, self.stripe_token)
    charge = create_stripe_charge(
      customer.id,
      amount_cents,
      description,
    )
    self.confirmation = charge.id
  end

  def refund!
    return nil unless self.source == "Stripe" && self.confirmation
    charge = retrieve_stripe_charge(self.confirmation)
    charge.refund
  end

  def amount_cents
    (amount_usd * 100).to_i
  end

  private

  #STRIPE has option for 'recipt_email' --> wondering what is in this email / if we want to use it
  def create_payment_intent(customer_id, payment_method_id)
    intent = Stripe::PaymentIntent.create({
      amount: amount_cents,
      customer: customer_id,
      confirm: true,
      currency: 'usd',
      payment_method: payment_method_id
    })
    return intent
  end

  def create_off_session_payment_intent(customer_id, payment_method_id)
    Stripe::PaymentIntent.create({
      amount: amount_cents,
      customer: customer_id,
      confirm: true,
      off_session: true,
      currency: 'usd',
      payment_method: payment_method_id
    })
  end

  def create_stripe_customer(email, source)
    Stripe::Customer.create(
      email: email,
      source: source,
    )
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
