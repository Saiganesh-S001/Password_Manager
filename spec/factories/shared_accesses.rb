FactoryBot.define do
  factory :shared_access do
    association :owner, factory: :user
    association :collaborator, factory: :user
  end
end
