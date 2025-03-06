FactoryBot.define do
  factory :password_record do
    username { Faker::Internet.user_name }
    password { Faker::Internet.password }
    url { Faker::Internet.url }
    title { Faker::Lorem.characters(number: 15) }
    association :user
  end
end
