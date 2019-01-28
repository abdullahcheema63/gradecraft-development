FactoryBot.define do
  factory :license do
    association :user
    expires { DateTime.now + 6.months }

    trait :expired do
      expires { DateTime.now - 6.months }
    end

    factory :standard_license do
      association :license_type, factory: :license_type_standard
    end

    factory :custom_license do
      association :license_type, factory: :license_type_custom
    end
  end
end