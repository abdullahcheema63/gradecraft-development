json.data @billing_schemes do |billing_scheme|
  json.type "billing_schemes"
  json.id billing_scheme.id.to_s
  json.attributes do
    json.id billing_scheme.id.to_s
    json.maxCourses billing_scheme.max_courses
    json.minCourses billing_scheme.min_courses
    json.pricePerCourse billing_scheme.price_per_course
    json.hide billing_scheme.hide
  end
end
