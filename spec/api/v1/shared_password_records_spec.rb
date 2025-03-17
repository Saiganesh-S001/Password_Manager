# spec/api/v1/shared_password_records_spec.rb
require 'rails_helper'

RSpec.describe 'SharedPasswordRecords API', type: :request do
  let!(:owner) { create(:user) }
  let!(:collaborator) { create(:user) }
  let!(:password_record) { create(:password_record, user: owner) }

  before do
    post '/api/v1/auth/login', params: { email: owner.email, password: owner.password }
    @token = JSON.parse(response.body)['token']
    @headers = { 'Authorization' => "Bearer #{@token}" }
  end

  describe 'POST /api/v1/shared_password_records' do
    it 'shares a password record with another user' do
      post '/api/v1/shared_password_records',
           headers: @headers,
           params: {
             password_record_id: password_record.id,
             email: collaborator.email
           }

      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)
      expect(json_response['password_record']['id']).to eq(password_record.id)
      expect(json_response['collaborator']['email']).to eq(collaborator.email)
    end

    it 'returns error when sharing with non-existent user' do
      post '/api/v1/shared_password_records',
           headers: @headers,
           params: {
             password_record_id: password_record.id,
             email: 'nonexistent@example.com'
           }

      expect(response).to have_http_status(:not_found)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to include('Invalid User')
    end

    it 'returns error when sharing with self' do
      post '/api/v1/shared_password_records',
           headers: @headers,
           params: {
             password_record_id: password_record.id,
             email: owner.email
           }

      expect(response).to have_http_status(:bad_request)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to include('Cannot share with yourself')
    end
  end

  describe 'GET /api/v1/shared_password_records/shared_with_me' do
    let!(:shared_record) do
      create(:shared_password_record,
             owner: owner,
             collaborator: collaborator,
             password_record: password_record)
    end

    it 'returns password records shared with the user' do
      # Login as collaborator to see shared records
      post '/api/v1/auth/login', params: { email: collaborator.email, password: collaborator.password }
      collab_token = JSON.parse(response.body)['token']
      collab_headers = { 'Authorization' => "Bearer #{collab_token}" }

      get '/api/v1/shared_password_records/shared_with_me',
          headers: collab_headers

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.first['password_record']['id']).to eq(password_record.id)
    end

    it 'returns empty array when no records are shared' do
      get '/api/v1/shared_password_records/shared_with_me',
          headers: @headers

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_empty
    end
  end

  describe 'GET /api/v1/shared_password_records/shared_by_me' do
    let!(:shared_record) do
      create(:shared_password_record,
             owner: owner,
             collaborator: collaborator,
             password_record: password_record)
    end

    it 'returns password records shared by the user' do
      get '/api/v1/shared_password_records/shared_by_me',
          headers: @headers

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.first['password_record']['id']).to eq(password_record.id)
      expect(json_response.first['collaborator']['email']).to eq(collaborator.email)
    end

    it 'returns empty array when user has not shared any records' do
      # Login as collaborator who hasn't shared any records
      post '/api/v1/auth/login', params: { email: collaborator.email, password: collaborator.password }
      collab_token = JSON.parse(response.body)['token']
      collab_headers = { 'Authorization' => "Bearer #{collab_token}" }

      get '/api/v1/shared_password_records/shared_by_me',
          headers: collab_headers

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_empty
    end
  end

  describe 'DELETE /api/v1/shared_password_records' do
    let!(:shared_record) do
      create(:shared_password_record,
             owner: owner,
             collaborator: collaborator,
             password_record: password_record)
    end

    it 'removes shared access to the password record' do
      expect {
        delete '/api/v1/shared_password_records',
               headers: @headers,
               params: {
                 password_record_id: password_record.id,
                 email: collaborator.email
               }
      }.to change(SharedPasswordRecord, :count).by(-1)

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to include('Shared access removed')
    end

    it 'returns error when trying to remove non-existent share' do
      delete '/api/v1/shared_password_records',
             headers: @headers,
             params: {
               password_record_id: password_record.id,
               email: 'nonexistent@example.com'
             }
      expect(response).to have_http_status(:not_found)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to include('Invalid User')
    end
  end

  describe 'authentication' do
    it 'returns unauthorized without valid token' do
      get '/api/v1/shared_password_records/shared_with_me'
      expect(response).to have_http_status(:unauthorized)

      get '/api/v1/shared_password_records/shared_by_me'
      expect(response).to have_http_status(:unauthorized)

      post '/api/v1/shared_password_records',
           params: {
             password_record_id: password_record.id,
             email: collaborator.email
           }
      expect(response).to have_http_status(:unauthorized)

      delete '/api/v1/shared_password_records',
             params: {
               password_record_id: password_record.id,
               email: collaborator.email
             }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end