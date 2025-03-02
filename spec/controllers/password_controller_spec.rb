require 'rails_helper'

RSpec.describe PasswordRecordsController, type: :controller do
  let(:user) { create(:user) }
  let(:password_record) { create(:password_record, user: user) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "returns a successful response" do
      get :index, params: {}  # Explicit params
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #show" do
    it "redirects to verification page if not verified" do
      session[:verified] = nil
      get :show, params: { id: password_record.id }
      expect(response).to redirect_to(verify_security_path)
    end

    it "shows the password record if verified" do
      session[:verified] = true
      get :show, params: { id: password_record.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST #create" do
    it "creates a new password record" do
      expect {
        post :create, params: { password_record: attributes_for(:password_record) }
      }.to change(PasswordRecord, :count).by(1)
      expect(response).to redirect_to(password_records_path)
    end
  end

  describe "PATCH #update" do
    it "updates the password record" do
      patch :update, params: { id: password_record.id, password_record: { title: "Updated Title" } }
      password_record.reload  # Ensure reload before expectation
      expect(password_record.title).to eq("Updated Title")
      expect(response).to redirect_to(password_record)
    end
  end

  describe "DELETE #destroy" do
    it "deletes the password record" do
      delete :destroy, params: { id: password_record.id }
      expect(PasswordRecord.exists?(password_record.id)).to be_falsey
      expect(response).to redirect_to(password_records_path)
    end
  end
end
