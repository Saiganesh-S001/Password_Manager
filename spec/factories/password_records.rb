FactoryBot.define do
  factory :password_record do
    username { Faker::Internet.user_name }
    password { Faker::Internet.password }
    url { Faker::Internet.url }
    title { "MyString" }
    association :user, factory: :user
  end
end
