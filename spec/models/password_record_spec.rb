require 'rails_helper'

RSpec.describe PasswordRecord, type: :model do
  let(:user) { create(:user) }
  let(:password_record) { build(:password_record, user: user) }
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
      original_password = password_record.password
      password_record.save!

      # Reload to get the encrypted version
      saved_record = PasswordRecord.find(password_record.id)
      expect(saved_record.password).to be_present
      expect(saved_record.password).not_to eq(original_password)
    end
  end
end
