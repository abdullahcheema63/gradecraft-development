FactoryGirl.define do
  factory :grade do
    association :assignment
    association :student, factory: :user

    factory :in_progress_grade do
      raw_points { Faker::Number.number(5) }
      score { raw_points }
      instuctor_modified true
      complete false
    end

    factory :student_visible_grade do
      raw_points { Faker::Number.number(5) }
      instuctor_modified true
      complete true
      student_visible true
    end
  end
end
