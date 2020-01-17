json.type "subscriptions"
json.id subscription.id.to_s

json.attributes do
  json.id subscription.id
  json.customer_id subscription.customer_id
  json.stripe_connection_error @stripe_connection_error
  json.is_expired subscription.is_expired?
  json.failed_last_payment subscription.failed_last_payment?
  json.within_grace_period subscription.within_grace_period?
  json.expires subscription.renewal_date
  json.billing_scheme_id subscription.billing_scheme_id.to_s
  json.created_at subscription.created_at
  json.updated_at subscription.updated_at
end

json.relationships do
  json.courses do
    json.data subscription.courses do |course|
      json.type "courses"
      json.id course.id.to_s
    end
  end if subscription.courses.any?

  json.payments do
    json.data subscription.payments do |payment|
      json.type "payments"
      json.id payment.id.to_s
    end
  end if subscription.payments.any?

  json.payment_methods do
    json.data @payment_methods do |payment_method|
      json.type "payment_methods"
      json.id payment_method.id.to_s
    end
  end if @payment_methods
end
