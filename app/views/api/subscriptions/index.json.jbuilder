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
      json.source                             payment.source
    end
  end
end
