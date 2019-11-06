json.data do
  json.type "payments"
  json.id @failed_payment.id.to_s
  json.attributes do
    json.id @failed_payment.id.to_s
    json.amount_usd @failed_payment.amount_usd
    json.status @failed_payment.status
    json.billing_scheme_id @failed_payment.billing_scheme_id
    json.payment_intent_id @failed_payment.payment_intent_id

    json.created_at @failed_payment.created_at
    json.updated_at @failed_payment.updated_at
    end

  json.relationships do
    json.courses do
      json.data @failed_payment.courses do |course|
        json.type "courses"
        json.id course.id.to_s
      end
    end
  end
end

json.included do
  json.array! @failed_payment.courses do |course|
    json.id course.id.to_s
    json.type "courses"

    json.attributes do
      json.id course.id.to_s
      json.name course.name
      json.number course.course_number
      json.year course.year
      json.semester course.semester
      json.created_at course.created_at
      json.published course.published
    end
  end
end
