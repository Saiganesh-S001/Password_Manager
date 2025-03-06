FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    display_name { Faker::Name.name }
    password { "password" }
    password_confirmation { "password" }
    encryption_key { SecureRandom.hex(32) }

    # won't work because validation happens before these callbacks are called
    # after(:build) do |user|
    #   user.encryption_key = SecureRandom.hex(32)
    #   user.save!
    #   user.reload
    # end



    # create vs build
    # create: create and save the user
    # build: create the user but not save it
  end
end
