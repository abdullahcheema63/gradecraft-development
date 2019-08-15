FactoryBot.define do
  factory :course_analytics_export do
    association :course
    association :owner, factory: :user

    local_file_path { "some-object-key" }
  end
end
