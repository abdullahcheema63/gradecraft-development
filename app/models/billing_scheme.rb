class BillingScheme < ApplicationRecord
  has_many :subscriptions

  # will this be custom created for each subscription ? has_one vs has_many
end
