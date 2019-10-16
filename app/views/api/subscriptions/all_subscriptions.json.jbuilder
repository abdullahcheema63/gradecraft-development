json.data @subscriptions do |subscription|
  json.type "subscriptions"
  json.id subscription.id.to_s
  json.attributes do
    json.id subscription.id.to_s
    json.user_id subscription.user_id
    json.renewal_date subscription.renewal_date
    json.created_at subscription.created_at
    json.updated_at subscription.updated_at
    json.billing_scheme_id subscription.billing_scheme_id
  end

  json.relationships do
    json.payments do
      json.data subscription.payments do |payment|
        json.type "payments"
        json.id payment.id.to_s
      end
    end if subscription.payments.any?
  end
end

json.included do
  @subscriptions.each do |subscription|
    json.array! subscription.payments do |payment|
      json.id payment.id.to_s
      json.type "payments"

      json.attributes do
        json.id payment.id.to_s
        json.amount_usd payment.amount_usd
        json.first_name payment.first_name
        json.last_name payment.last_name
        json.created_at payment.created_at
        json.billing_scheme_id payment.billing_scheme_id
      end
    end if subscription.payments.any?
  end
end
