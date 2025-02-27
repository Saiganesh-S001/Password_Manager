require 'rails_helper'

RSpec.describe User, type: :model do
  let(:subject) { build(:user) }
  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end
  it "is not valid without a password" do
    subject.password = nil
    expect(subject).to_not be_valid
  end
  it "is not valid without a email" do
    subject.email  = nil
    expect(subject).to_not be_valid
  end

  context "encryption" do
    it "encrypts the password before saving" do
      subject.save!
      saved_subject = User.find(subject.id)
      expect(saved_subject.encrypted_password).to be_present
      expect(saved_subject.encrypted_password).not_to eq("password")
    end
  end
end
