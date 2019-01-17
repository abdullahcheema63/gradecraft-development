class Payment < ApplicationRecord
  before_create :set_defaults

  belongs_to :license
  attr_accessor :stripe_token

  def set_defaults
    self.source ||= self.stripe_token ? "Stripe" : nil
  end

  def charge
    return nil unless self.stripe_token
    customer = Stripe::Customer.create(
      email: license.user.email,
      source: self.stripe_token,
    )
    charge = Stripe::Charge.create(
      customer: customer.id,
      amount: amount_cents,
      description: license.license_type.name + " Exp.: " + license.expires.to_s,
      currency: "usd",
    )
    self.confirmation = charge.id
  end

  def refund
    return nil unless self.source == "Stripe" && self.confirmation
    charge = Stripe::Charge.retrieve(self.confirmation)
    charge.refund
  end

  def amount_cents
    (amount_usd * 100).to_i
  end
end
