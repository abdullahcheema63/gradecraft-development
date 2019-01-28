json.type "licenses"
json.id license.id.to_s

json.attributes do
  json.is_expired license.is_expired?
  json.expires license.expires
  json.license_type_id license.license_type_id
  json.license_type_name license.license_type.name
  json.max_courses license.max_courses
  json.max_students license.max_students
  json.created_at license.created_at
  json.updated_at license.updated_at
end

json.relationships do
  json.payments do
    json.data license.payments do |payment|
      json.type "payment"
      json.id payment.id.to_s
    end
  end if license.payments.any?
end
