# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    organisation { Organisation.first || association(:organisation) }
    email { Faker::Internet.email }
    password { 'test1234' }
    password_confirmation { 'test1234' }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    confirmed_at { Date.today }
    terms { true }
    approved { true }

    trait :admin do
      admin { true }
      organisation { Organisation.first || association(:organisation) }
    end

    trait :alt_admin do
      admin { true }
      organisation { association(:organisation) }
    end

    trait :unapproved do
      approved { false }
      organisation { association(:organisation) }
    end
  end

end
