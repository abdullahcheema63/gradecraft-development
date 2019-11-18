FactoryBot.define do
  factory :submissions_export do
    association :course
    association :professor, factory: :user
    association :team
    association :assignment

    trait :use_groups do
      use_groups { true }
    end
  end
end
