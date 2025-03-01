FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    display_name { Faker::Name.name }
    password { "password" }
    password_confirmation {"password"}
  end
end