FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    username { Faker::Internet.user_name }
    email { Faker::Internet.email }
    password { "secret" }

    after :create, &:activate!

    factory :professor do
      transient do
        course nil
      end

      course_membership do
        CourseMembership.find_or_create_by \
          user: self,
          course: course,
          role: "professor"
      end
    end
  end
end
