class Payment < ApplicationRecord
  belongs_to :subscription

  has_and_belongs_to_many :courses

  attr_accessor :payment_method_id

  validates_presence_of :amount_usd

  def charge_customer
    customer_id = self.subscription.customer_id
    customer = Stripe::Customer.retrieve(customer_id)

    payment_method_id = get_payment_method_id(customer)
    create_payment_intent(customer_id, payment_method_id)
  end

  def charge_customer_off_session
    customer_id = self.subscription.customer_id
    customer = Stripe::Customer.retrieve(customer_id)

    payment_method_id = get_payment_method_id(customer)

    create_off_session_payment_intent(customer_id, payment_method_id)
  end

  def refund!
    return nil unless self.payment_intent_id == "Stripe" && self.confirmation
    charge = retrieve_stripe_charge(self.confirmation)
    charge.refund
  end

  def amount_cents
    (amount_usd * 100).to_i
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

  #STRIPE has option for 'recipt_email' --> wondering what is in this email / if we want to use it
  def create_payment_intent(customer_id, payment_method_id)
    intent = Stripe::PaymentIntent.create({
      amount: amount_cents,
      customer: customer_id,
      confirm: true,
      currency: 'usd',
      payment_method: payment_method_id
    })
  end

  def create_off_session_payment_intent(customer_id, payment_method_id)
    Stripe::PaymentIntent.create({
      amount: amount_cents,
      currency: 'usd',
      customer: customer_id,
      confirm: true,
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
