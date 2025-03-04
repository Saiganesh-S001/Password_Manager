require 'rails_helper'

RSpec.describe PasswordRecord, type: :model do
  let!(:user) { create(:user) }
  let!(:password_record) { create(:password_record, user: user) }

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:username) }
    it { should validate_presence_of(:password) }
    it { should validate_presence_of(:url) }
    it { should validate_length_of(:password).is_at_least(8) }
    it { should validate_length_of(:title).is_at_least(3).is_at_most(20) }
    it { should validate_uniqueness_of(:title) }
    it { should validate_uniqueness_of(:username).scoped_to([:user_id, :url]) }
  end

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
      expect(saved_password_record.password).not_to eq(password_record.password)
    end
  end

  describe 'friendly_id' do
    it "generates slug from title"  do
      record = create(:password_record, title: "My Password")
      expect(record.slug).to eq("my-password")
    end
  end
end
