@license_types = []

@license_types.push({
  name: "Higher Ed #1",
  default_max_courses: 2,
  default_max_students: 350,
  default_duration_months: 6,
  price_usd: 40.0,
})

@license_types.push({
  name: "Higher Ed #2",
  default_max_courses: 1,
  default_max_students: 350,
  default_duration_months: 6,
  price_usd: 60.0,
})

@license_types.push({
  name: "K-12",
  default_max_courses: 10,
  default_max_students: 100,
  default_duration_months: 6,
  price_usd: 120.0,
})

@license_types.push({
  name: "Custom",
  default_duration_months: 24,
  hide: true,
})
