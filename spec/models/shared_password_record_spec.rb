require 'rails_helper'

RSpec.describe SharedPasswordRecord, type: :model do
  let(:owner) { create(:user) }
  let(:collaborator) { create(:user) }
  let(:password_record) { create(:password_record, user: owner) }

  let(:shared_password_record) { create(:shared_password_record, owner: owner, collaborator: collaborator, password_record: password_record) }

  it "is valid with valid attributes" do
    expect(shared_password_record).to be_valid
  end

  it "is invalid without an owner" do
    shared_password = SharedPasswordRecord.new(collaborator: collaborator, password_record: password_record)
    expect(shared_password).not_to be_valid
  end

  it "is invalid without a collaborator" do
    shared_password = SharedPasswordRecord.new(owner: owner, password_record: password_record)
    expect(shared_password).not_to be_valid
  end

  it "is invalid without a password record" do
    shared_password = SharedPasswordRecord.new(owner: owner, collaborator: collaborator)
    expect(shared_password).not_to be_valid
  end

  it "enforces uniqueness of shared password per user" do
    SharedPasswordRecord.create(owner: owner, collaborator: collaborator, password_record: password_record)
    duplicate = SharedPasswordRecord.new(owner: owner, collaborator: collaborator, password_record: password_record)
    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:collaborator_id]).to include("Already shared with this user")
  end
end