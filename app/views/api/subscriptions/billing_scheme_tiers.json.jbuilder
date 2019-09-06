json.data @billing_schemes do |billing_scheme|
  json.type "billing_schemes"
  json.id billing_scheme.id.to_s
  json.attributes do
    json.id billing_scheme.id.to_s
    json.max_courses billing_scheme.max_courses
    json.min_courses billing_scheme.min_courses
    json.price_per_course billing_scheme.price_per_course
    json.hide billing_scheme.hide
  end
end
