FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    display_name { Faker::Name.name }
    password { "password" }
    password_confirmation { "password" }
    encryption_key { SecureRandom.hex(32) }

    after(:build) do |user|
      user.encryption_key ||= SecureRandom.hex(32)
    end
  end
end
