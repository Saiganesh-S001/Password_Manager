require 'rails_helper'

RSpec.describe "PasswordRecords", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:password_record) { FactoryBot.create(:password_record, user: user) }
  before { sign_in user }

  describe "GET /password_records" do
    it "returns all password records" do
      get password_records_path
      expect(response).to have_http_status(200)
    end

    it "returns the correct records" do
      get password_records_path
      expect(response.body).to include(password_record.title)
    end
  end
end
