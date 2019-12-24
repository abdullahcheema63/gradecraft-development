json.data @subscriptions do |subscription|
  json.type "subscriptions"
  json.id subscription.id.to_s
  json.attributes do
    json.id subscription.id.to_s
    json.user_id subscription.user_id
    json.first_name subscription.user.first_name
    json.last_name subscription.user.last_name
    json.email subscription.user.email
    json.renewal_date subscription.renewal_date
    json.cost_per_month subscription.cost_per_month
    json.subscribed_courses subscription.courses.count
    json.created_at subscription.created_at
    json.updated_at subscription.updated_at
    json.failed_last_payment subscription.payments.last.failed
    json.last_payment_date subscription.payments.last.created_at
    json.billing_scheme_id subscription.billing_scheme_id
  end

  json.relationships do
    json.payments do
      json.data subscription.payments do |payment|
        json.type "payments"
        json.id payment.id.to_s
      end
    end if subscription.payments.any?

    json.courses do
      json.data subscription.courses do |course|
        json.type "courses"
        json.id course.id.to_s
      end
    end if subscription.courses.any?
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
        json.created_at payment.created_at
        json.billing_scheme_id payment.billing_scheme_id
        json.failed payment.failed
      end
    end if subscription.payments.any?
    json.array! subscription.courses do |course|
      json.id course.id.to_s
      json.type "courses"

      json.attributes do
        json.id course.id.to_s
        json.name course.name
        json.url change_course_path course
        json.published course.published
        json.active course.active?
      end
    end if subscription.courses.any?
  end
end
