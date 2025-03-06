require 'rails_helper'

RSpec.describe 'PasswordRecordsAuth', type: :request do
  let!(:one_user) { create(:user) }
  let!(:two_user) { create(:user) }
  let!(:one_password_record) { create(:password_record, user: one_user) }
  let!(:two_password_record) { create(:password_record, user: two_user) }

  before do
    sign_in one_user
  end


  describe 'GET /password_records' do
    it "should see own password records" do
      get password_records_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(one_password_record.title)
    end

    it "should not see other user's password record" do
      get password_records_path
      expect(response.body).not_to include(two_password_record.title)
    end
  end

  describe 'DELETE /password_records/:id' do
    it "should delete own password record" do
      delete password_record_path(one_password_record)
      expect(response).to redirect_to(password_records_path)
      expect(response).to have_http_status(:see_other)
    end

    it "should not delete other user's password record" do
      delete password_record_path(two_password_record)
      expect(response).to redirect_to(password_records_path)
      expect(flash[:alert]).to eq("You are not allowed to access this password record.")
    end
  end
end
