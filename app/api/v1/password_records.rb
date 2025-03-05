module V1
  class PasswordRecords < Grape::API
    helpers do
      def authenticate_user!
        token = headers["Authorization"]&.split(" ")&.last
        error!("Unauthorized", 401) unless token


        payload = Warden::JWTAuth::TokenDecoder.new.call(token)
        puts "payload: #{payload}"
        @current_user = User.find_by(jti: payload["jti"])

        error!("Unauthorized", 401) unless @current_user
      end

      def current_user
        @current_user
      end
    end

    before do
      authenticate_user!
    end

    resource :password_records do
      desc "Get all password records"
      get do
        owner_records = current_user.password_records
        shared_records = current_user.shared_password_records
        received_records = current_user.received_password_records
        all_records = {
          owner_records: owner_records,
          shared_records: shared_records,
          received_records: received_records
        }
        puts "all_records: #{all_records}"
        present owner_records, with: Entities::PasswordRecordEntity # make new entity for all records
      end

      desc "Create a password record"
      params do
        requires :title, type: String, desc: "Title"
        requires :password, type: String, desc: "Password"
        requires :url, type: String, desc: "URL"
        requires :username, type: String, desc: "Username"
      end
      post do
        record = current_user.password_records.create!(declared(params))
        present record, with: Entities::PasswordRecordEntity
      end

      route_param :id do
        desc "Get a password record"
        get do
          record = current_user.password_records.find(params[:id])
          present record, with: Entities::PasswordRecordEntity
        end

        desc "Update a password record"
        params do
          requires :title, type: String, desc: "Title"
          requires :password, type: String, desc: "Password"
          requires :url, type: String, desc: "URL"
          requires :username, type: String, desc: "Username"
        end
        put do
          record = current_user.password_records.find(params[:id])
          record.update!(declared(params))
          present record, with: Entities::PasswordRecordEntity
        end

        desc "Delete a password record"
        delete do
          record = current_user.password_records.find(params[:id])
          record.destroy
          present record, with: Entities::PasswordRecordEntity
        end
      end
    end
  end
end
