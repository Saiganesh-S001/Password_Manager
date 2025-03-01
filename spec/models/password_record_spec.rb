require 'rails_helper'

RSpec.describe PasswordRecord, type: :model do
  let(:password_record) { FactoryBot.build(:password_record) }
  context 'validations' do
    it "is valid with valid attributes" do
      expect(password_record).to be_valid
    end

    it "is invalid without a title" do
      password_record.title = nil
      expect(password_record).not_to be_valid
    end
  end

  context 'encryption' do
    it "encrypts the password before saving" do
      password_record.save!
      saved_password_record = PasswordRecord.last
      expect(saved_password_record.password).to be_present
    end
  end
end
