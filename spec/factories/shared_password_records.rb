FactoryBot.define do
  factory :shared_password_record do
    association :owner, factory: :user
    association :collaborator, factory: :user
    association :password_record
  end
end
