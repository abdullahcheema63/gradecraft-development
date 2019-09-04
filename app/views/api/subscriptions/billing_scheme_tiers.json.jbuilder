json.data @billing_schemes do |billing_scheme|
  json.type "billing_schemes"
  json.id billing_scheme.id.to_s
  json.attributes do
    json.id billing_scheme.id.to_s
    json.default_max_courses billing_schemes.max_courses
    json.default_max_students billing_scheme.min_courses
    json.price_usd billing_scheme.price_per_course
    json.hide billing_scheme.hide
  end
end
