class Payment < ApplicationRecord
  belongs_to :license
  attr_accessor :stripe_token

  def charge_stripe(stripe_token)
    customer = Stripe::Customer.create(
      email: license.user.email,
      source: stripe_token,
    )
    charge = Stripe::Charge.create(
      customer: customer.id,
      amount: amount_cents,
      # description: license.license_type.name + " Exp.: " + license.expires.to_s,
      currency: "usd",
    )
    confirmation = charge.id
  end

  def amount_cents
    (amount_usd * 100).to_i
  end
end
