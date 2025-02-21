json.extract! password_record, :id, :username, :password, :url, :user_id, :created_at, :updated_at
json.url password_record_url(password_record, format: :json)
