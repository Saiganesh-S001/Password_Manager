require 'rails_helper'

RSpec.describe 'PasswordRecords API', type: :request do
  let!(:user) { create(:user) }
  let!(:password_record) { create(:password_record, user: user) }

  before do
    post '/api/v1/auth/login', params: { email: user.email, password: user.password }
    @token = JSON.parse(response.body)['token']
    @headers = { 'Authorization' => "Bearer #{@token}" }
  end

  describe 'GET /api/v1/password_records' do
    it 'returns all password records' do
      get '/api/v1/password_records', headers: @headers
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      puts json_response
      expect(json_response).to be_an(Object)
      expect(json_response["owner_records"].length).to eq(1)
      expect(json_response["owner_records"].first['title']).to eq(password_record.title)
    end

    it 'returns filtered password records with search' do
      get '/api/v1/password_records',
          headers: @headers,
          params: { search_by_title: password_record.title }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an(Object)
      expect(json_response["owner_records"].length).to eq(1)
      expect(json_response["owner_records"].first['title']).to eq(password_record.title)
    end

    it 'returns empty array for non-matching search' do
      get '/api/v1/password_records',
          headers: @headers,
          params: { search_by_title: 'nonexistent' }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an(Object)
      expect(json_response["owner_records"]).to be_empty
    end

    context 'with multiple search parameters' do
      let!(:another_record) { create(:password_record,
        user: user,
        title: 'Test Title',
        username: 'testuser',
        url: 'https://test.com'
      )}

      it 'searches by username' do
        get '/api/v1/password_records',
            headers: @headers,
            params: { search_by_username: 'testuser' }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to be_an(Object)
        expect(json_response["owner_records"].length).to eq(1)
        expect(json_response["owner_records"].first['username']).to eq('testuser')
      end

      it 'searches by url' do
        get '/api/v1/password_records',
            headers: @headers,
            params: { search_by_url: 'test.com' }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to be_an(Object)
        expect(json_response["owner_records"].length).to eq(1)
        expect(json_response["owner_records"].first['url']).to eq('https://test.com')
      end
    end
  end

  describe 'POST /api/v1/password_records' do
    let(:valid_attributes) {
      {
        title: 'Test Password',
        username: 'testuser',
        password: 'testStrongPassword123!',
        url: 'https://test.com'
      }
    }

    it 'creates a new password record' do
      expect {
        post '/api/v1/password_records',
             headers: @headers,
             params: valid_attributes
      }.to change(PasswordRecord, :count).by(1)

      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)
      expect(json_response['title']).to eq(valid_attributes[:title])
      expect(json_response['username']).to eq(valid_attributes[:username])
      expect(json_response['url']).to eq(valid_attributes[:url])
    end

    it 'returns error for invalid parameters' do
      post '/api/v1/password_records',
           headers: @headers,
           params: { title: 'test' }

      expect(response).to have_http_status(:bad_request)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to include('password is missing')
    end
  end

  describe 'PUT /api/v1/password_records/:id' do
    let(:update_attributes) {
      {
        title: 'Updated Title',
        username: password_record.username,
        password: password_record.password,
        url: password_record.url
      }
    }

    it 'updates a password record' do
      put "/api/v1/password_records/#{password_record.id}",
          headers: @headers,
          params: update_attributes

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['title']).to eq('Updated Title')
      expect(password_record.reload.title).to eq('Updated Title')
    end

    it 'returns error for non-existent record' do
      put "/api/v1/password_records/999999",
          headers: @headers,
          params: update_attributes

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /api/v1/password_records/:id' do
    it 'returns a specific password record' do
      get "/api/v1/password_records/#{password_record.id}",
          headers: @headers

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['id']).to eq(password_record.id)
      expect(json_response['title']).to eq(password_record.title)
    end

    it 'returns error for non-existent record' do
      get "/api/v1/password_records/999999",
          headers: @headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/v1/password_records/:id' do
    it 'deletes a password record' do
      expect {
        delete "/api/v1/password_records/#{password_record.id}",
               headers: @headers
      }.to change(PasswordRecord, :count).by(-1)

      expect(response).to have_http_status(:ok)
    end

    it 'returns error for non-existent record' do
      delete "/api/v1/password_records/999999",
             headers: @headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'authentication' do
    it 'requires authentication for all endpoints' do
      # GET index
      get '/api/v1/password_records'
      expect(response).to have_http_status(:unauthorized)

      # POST create
      post '/api/v1/password_records'
      expect(response).to have_http_status(:unauthorized)

      # GET show
      get "/api/v1/password_records/#{password_record.id}"
      expect(response).to have_http_status(:unauthorized)

      # PUT update
      put "/api/v1/password_records/#{password_record.id}"
      expect(response).to have_http_status(:unauthorized)

      # DELETE
      delete "/api/v1/password_records/#{password_record.id}"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
