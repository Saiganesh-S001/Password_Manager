require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:user) { create(:user) }

  describe "Authentication" do
    it "redirects to login when unauthenticated" do
      get password_records_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "allows authenticated users to access home page" do
      sign_in user
      get password_records_path
      expect(response).to have_http_status(:success)
    end
  end
end
