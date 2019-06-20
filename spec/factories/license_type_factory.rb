FactoryBot.define do
  factory :license_type do
    factory :license_type_standard do
      name { "Higher Ed" }
      default_max_courses { 6 }
      default_max_students { 40 }
      default_duration_months { 12 }
      price_usd { 20.0 }
    end

    factory :license_type_custom do
      name { "Custom" }
      hide { true }
    end
  end
end