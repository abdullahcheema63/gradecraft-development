class Payment < ApplicationRecord
  before_create :set_defaults

  belongs_to :license
  attr_accessor :stripe_token

  validates_presence_of :first_name, :last_name, :organization, :phone, :addr1, :city, :country, :amount_usd

  def set_defaults
    self.source ||= self.stripe_token ? "Stripe" : nil
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
