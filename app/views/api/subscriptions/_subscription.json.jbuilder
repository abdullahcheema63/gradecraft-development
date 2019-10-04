json.type "subscriptions"
json.id subscription.id.to_s

json.attributes do
  json.id subscription.id
  json.customer_id subscription.customer_id
  json.is_expired subscription.is_expired?
  json.expires subscription.renewal_date
  json.license_type_id subscription.billing_scheme_id.to_s
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
