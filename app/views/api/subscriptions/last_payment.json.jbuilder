json.data do
  json.type "payments"
  json.id @last_payment.id.to_s
  json.attributes do
    json.id @last_payment.id.to_s
    json.amount_usd @last_payment.amount_usd
    json.status @last_payment.status
    json.failed @last_payment.failed
    json.abandoned @last_payment.abandoned
    json.billing_scheme_id @last_payment.billing_scheme_id
    json.payment_intent_id @last_payment.payment_intent_id

    json.created_at @last_payment.created_at
    json.updated_at @last_payment.updated_at
    end

  json.relationships do
    json.courses do
      json.data @last_payment.courses do |course|
        json.type "courses"
        json.id course.id.to_s
      end
    end
  end
end

json.included do
  json.array! @last_payment.courses do |course|
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
