require 'rails_helper'

RSpec.describe "PasswordRecords", type: :request do
  include Devise::Test::IntegrationHelpers
  let!(:user) { create(:user) }
  let!(:password_record) { create(:password_record, user: user) }

  before do
    sign_in user
  end

  describe "GET /password_records" do
    it "returns all password records" do
      get password_records_path
      expect(response).to have_http_status(200)
    end

    it "returns the correct records" do
      record = password_record # password record is not created in the database until u create a record here (why?)
      get password_records_path
      expect(response.body).to include(record.title)
    end
  end

  describe "POST /password_records" do
    it "creates a new password record" do
      expect {
        puts attributes_for(:password_record)
        post password_records_path, params: { password_record: attributes_for(:password_record) }
        puts "Response status: #{response.status}"
        puts "Response body: #{response.body}"
      }.to change(PasswordRecord, :count).by(1)
      expect(response).to redirect_to(password_records_path)
    end
  end

  describe "PATCH /password_records/:id" do
    it "updates the record if user is owner" do
      original_record = password_record
      patch password_record_path(original_record), params: { password_record: { title: "Updated Title", username: "test", password: "password_new", url: "http://test.com" } }
      # puts "Response location: #{response.location}" if response.redirect?
      expect(original_record.reload.title).to eq("Updated Title")

      expect(response).to have_http_status(:redirect)

      # get password_record_path(original_record)
      # expect(response.body).to include("Updated Title")
    end
  end

  describe "DELETE /password_records/:id" do
    it "allows the owner to delete" do
      expect {
        delete password_record_path(password_record)
      }.to change(PasswordRecord, :count).by(-1)

      expect(response).to redirect_to(password_records_path)
    end

    it "prevents non-owners from deleting" do
      other_user = create(:user)
      sign_in other_user

      expect {
        delete password_record_path(password_record)
      }.not_to change(PasswordRecord, :count)

      expect(response).to redirect_to(password_records_url)
    end
  end
end
