json.data do
  json.partial! "api/licenses/license", license: @license
end

json.included do
  json.array! @courses do |course|
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
  json.array! @license_types do |license_type|
    json.type                                 "license_types"
    json.id                                   license_type.id.to_s

    json.attributes do
      json.id license_type.id.to_s
      json.name license_type.name
      json.default_max_courses license_type.default_max_courses
      json.default_max_students license_type.default_max_students
      json.default_duration_months license_type.default_duration_months
      json.price_usd license_type.price_usd
      json.hide license_type.hide
    end
  end
end
