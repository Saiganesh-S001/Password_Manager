require 'rails_helper'

RSpec.describe "Auth API", type: :request do
  let!(:user) { create(:user, email: "test@example.com", password: "password") }
  let(:auth_header) { { "Authorization" => "Bearer #{get_auth_token(user)}" } }

  describe "POST /api/v1/auth/register" do
    let(:valid_params) do
      {
      email: "test@test.com",
        password: "password",
        display_name: "Test User"
      }
    end

    it "registers a new user" do
      post "/api/v1/auth/register", params: valid_params
      expect(response).to have_http_status(:created)
      expect(User.count).to eq(2)
      expect(User.last.email).to eq("test@test.com")
      expect(User.last.display_name).to eq("Test User")
    end

    it "returns errors for missing fields" do
      post "/api/v1/auth/register",
           params: { email: "test@test.com" }.to_json,
           headers: { "CONTENT_TYPE" => "application/json" }

      # expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("password is missing")
      expect(response.body).to include("display_name is missing")
      expect(User.count).to eq(1)
    end
  end

  describe "POST /api/v1/auth/login" do
    it "logs in a user with valid credentials" do
      post '/api/v1/auth/login', params: { email: user.email, password: "password" }
      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)
      expect(json_response["token"]).to be_present
    end

    it "returns errors for invalid credentials" do
      post '/api/v1/auth/login', params: { email: "test@test.com", password: "password" }
      expect(response).to have_http_status(:unauthorized)
      json_response = JSON.parse(response.body)
      expect(json_response["error"]).to be_present
      expect(json_response["error"]).to eq("Invalid email or password")
    end
  end

  describe "PUT /api/v1/auth/update" do
    let(:valid_update_params) do
      {
        password: "newpassword123",
        current_password: "password",
        display_name: "Test User"
      }
    end

    context "with valid current password" do
      it "updates the user" do
        put '/api/v1/auth/update', params: valid_update_params, headers: auth_header
        expect(response).to have_http_status(:ok)
        expect(user.reload.display_name).to eq("Test User")
        expect(user.valid_password?("newpassword123")).to be_truthy
      end
    end

    context "with invalid current password" do
      it "returns error for incorrect current password" do
        put '/api/v1/auth/update', params: valid_update_params.merge(current_password: "wrongpassword"), headers: auth_header
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to be_present
        expect(json_response["error"]).to eq("Invalid current password")
      end

      it "returns error for missing current password" do
        put '/api/v1/auth/update', params: valid_update_params.except(:current_password), headers: auth_header
        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to be_present
        expect(json_response["error"][0]).to eq("current_password is missing")
      end
    end

    context "when user is not authenticated" do
      it "returns error for unauthenticated user" do
        put '/api/v1/auth/update', params: valid_update_params, headers: { "Authorization" => "Bearer invalid_token" }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /api/v1/auth/logout" do
    it "invalidates the user's token" do
      original_jti = user.jti
      post '/api/v1/auth/logout', headers: auth_header
      expect(response).to have_http_status(:no_content)
      expect(user.reload.jti).not_to eq(original_jti)
    end

    it "returns error for unauthenticated user" do
      post '/api/v1/auth/logout', headers: { "Authorization" => "Bearer invalid_token" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /api/v1/auth/delete" do
    let(:valid_delete_params) do
      {
        current_password: "password"
      }
    end

    it "deletes a user" do
      expect {
        delete '/api/v1/auth/delete', params: valid_delete_params, headers: auth_header
      }.to change(User, :count).by(-1)
      expect(response).to have_http_status(:no_content)
      expect(User.find_by(email: user.email)).to be_nil
    end

    it "handles deletion for non-existent user" do
      expect {
        delete '/api/v1/auth/delete', headers: auth_header
      }.not_to change(User, :count)
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns error for incorrect current password" do
      expect {
        delete '/api/v1/auth/delete', params: valid_delete_params.merge(current_password: "wrongpassword"), headers: auth_header
      }.not_to change(User, :count)
      expect(response).to have_http_status(:unauthorized)
      expect(User.exists?(user.id)).to be_truthy
    end

    it "returns error for missing current password" do
      expect {
        delete '/api/v1/auth/delete', params: valid_delete_params.except(:current_password), headers: auth_header
      }.not_to change(User, :count)
    end
  end

  def get_auth_token(user)
    post "/api/v1/auth/login", params: { email: user.email, password: "password" }
    JSON.parse(response.body)["token"]
  end
end
