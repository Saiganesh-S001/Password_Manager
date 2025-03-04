require 'rails_helper'

RSpec.describe "PasswordRecords API", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:user) { create(:user) }
  let!(:password_record1) { create(:password_record, user: user, title: "Test", username: "test_user") }
  let!(:password_record2) { create(:password_record, user: user, title: "Hello", username: "other_user") }

  before { sign_in user }

  describe "GET /password_records" do
    it "returns all password records" do
      get password_records_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('<p class="text-lg font-medium">Test</p>')
      expect(response.body).to include('<p class="text-lg font-medium">Hello</p>')
    end

    it "returns the correct records when searching by title" do
      get password_records_path, params: { search_by_title: "Test" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('<p class="text-lg font-medium">Test</p>')
      expect(response.body).not_to include('<p class="text-lg font-medium">Hello</p>')
    end

    it "returns the correct records when searching by username" do
      get password_records_path, params: { search_by_username: "test_user" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('<p class="text-lg font-medium">Test</p>')
      expect(response.body).not_to include('<p class="text-lg font-medium">Hello</p>')
    end
  end

  describe "POST /password_records" do
    it "creates a new password record" do
      expect {
        post password_records_path, params: { password_record: attributes_for(:password_record) }
      }.to change(PasswordRecord, :count).by(1)

      expect(response).to have_http_status(:redirect)
      follow_redirect!
      expect(response.body).to include("Password record was successfully created")
    end
  end

  describe "PATCH /password_records/:id" do
    it "updates the record if user is the owner" do
      patch password_record_path(password_record1), params: { password_record: { title: "Updated Title" } }

      expect(response).to have_http_status(:redirect)
      expect(password_record1.reload.title).to eq("Updated Title")
    end
  end

  describe "DELETE /password_records/:id" do
    it "allows the owner to delete" do
      expect {
        delete password_record_path(password_record1)
      }.to change(PasswordRecord, :count).by(-1)

      expect(response).to have_http_status(:redirect)
    end

    it "prevents non-owners from deleting" do
      other_user = create(:user)
      sign_in other_user

      expect {
        delete password_record_path(password_record1)
      }.not_to change(PasswordRecord, :count)

      expect(response).to redirect_to(password_records_url)
    end
  end
end
