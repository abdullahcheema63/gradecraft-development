json.type "licenses"
json.id license.id.to_s

json.attributes do
  json.id license.id
  json.is_expired license.is_expired?
  json.expires license.expires
  json.license_type_id license.license_type_id.to_s
  json.license_type_name license.license_type.name
  json.max_courses license.max_courses
  json.max_students license.max_students
  json.created_at license.created_at
  json.updated_at license.updated_at
end

json.relationships do
  json.courses do
    json.data license.courses do |course|
      json.type "courses"
      json.id course.id.to_s
    end
  end
  json.payments do
    json.data license.payments do |payment|
      json.type "payments"
      json.id payment.id.to_s
    end
  end if license.payments.any?
end
