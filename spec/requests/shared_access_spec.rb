require 'rails_helper'

RSpec.describe "SharedAccess", type: :request do
  let(:owner) { create(:user) }
  let(:collaborator) { create(:user) }
  let!(:password_record) { create(:password_record, user: owner) }

  before { sign_in owner }

  describe "POST /shared_access" do
    it "allows sharing access" do
      expect {
        post shared_access_index_path, params: { email: collaborator.email } # should use only index_path and not shared_access_path
      }.to change(SharedPasswordRecord, :count).by(owner.password_records.count)

      expect(response).to redirect_to(password_records_path)
      expect(flash[:notice]).to include("Access shared with #{collaborator.email}")
    end

    it "allows sharing a specific password record" do
      expect {
        post shared_access_index_path, params: { email: collaborator.email, password_record_id: password_record.id }
      }.to change(SharedPasswordRecord, :count).by(1)

      expect(response).to redirect_to(password_records_path)
      expect(flash[:notice]).to include("Access shared with #{collaborator.email}")
    end

    it "prevents sharing with self" do
      post shared_access_index_path, params: { email: owner.email }
      expect(response).to redirect_to(password_records_path)
      expect(flash[:alert]).to include("Invalid user")
    end
  end

  describe "DELETE /shared_access/:id" do
    let!(:shared_access) { owner.owned_shares.create(collaborator: collaborator) }

    it "removes shared access" do
      expect {
        delete shared_access_path(shared_access.collaborator_id)
      }.to change(SharedAccess, :count).by(-1)

      expect(response).to redirect_to(password_records_path)
    end

    it "removes access to specific record" do
      shared_access = SharedPasswordRecord.create(owner: owner, collaborator: collaborator, password_record: password_record)
      expect {
        delete shared_access_path(shared_access.collaborator_id, params: { password_record_id: password_record.id })
      }.to change(SharedPasswordRecord, :count).by(-1)
    end
  end
end
