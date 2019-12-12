json.data do
  json.partial! "api/subscriptions/subscription", subscription: @subscription
end

json.included do
  json.array! @subscription.courses.each do |course|
    json.type                                 "courses"
    json.id                                   course.id.to_s

    json.attributes do
      json.id                                 course.id.to_s
      json.name                               course.name
      json.course_number                      course.course_number
      json.semester                           course.semester
      json.year                               course.year
    end
  end
  json.array! @payments do |payment|
    json.type                                 "payments"
    json.id                                   payment.id.to_s

    json.attributes do
      json.id                                 payment.id.to_s
      json.amount_usd                         payment.amount_usd
    end
  end
  json.array! @payment_methods do |payment_method|
    json.type "payment_methods"
    json.id payment_method.id.to_s
    json.attributes do
      json.id payment_method.id.to_s
      if payment_method.metadata.first
        json.nickname payment_method.metadata.nickname
      end
      json.full_name payment_method.billing_details.name
      json.city payment_method.billing_details.address.city
      json.addr1 payment_method.billing_details.address.line1
      json.addr2 payment_method.billing_details.address.line2
      json.postal_code payment_method.billing_details.address.postal_code
      json.phone payment_method.billing_details.phone
      json.country payment_method.card.country
      json.last4 payment_method.card.last4
      json.exp_month payment_method.card.exp_month
      json.exp_year payment_method.card.exp_year
      json.brand payment_method.card.brand
      if payment_method.id == @default_payment_method_id
        json.default_payment_method true
      else
        json.default_payment_method false
      end
    end
  end if @payment_methods
end
