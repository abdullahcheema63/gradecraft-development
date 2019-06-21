json.data @license_types do |license_type|
  json.type "license_types"
  json.id license_type.id.to_s
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
