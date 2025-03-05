module V1
  class SharedPasswordRecords < Grape::API
    helpers do
      def authenticate_user!
        token = headers["Authorization"]&.split(" ")&.last
        error!("Unauthorized", 401) unless token

        payload = Warden::JWTAuth::TokenDecoder.new.call(token)
        @current_user = User.find_by(jti: payload["jti"])
        error!("Unauthorized", 401) unless @current_user
      end

      def current_user
        @current_user
      end

      def shared_password_records
        current_user.shared_password_records
      end
    end

    before do
      authenticate_user!
    end

    resource :shared_password_records do
      desc "Share a password record with another user"
      params do
        requires :password_record_id, type: Integer, desc: "The ID of the password record to share"
        requires :email, type: String, desc: "The email of the user to share the password record with"
      end
      post do
        collaborator = User.find_by(email: params[:email])
        error!("Invalid User", 404) if collaborator.nil? || collaborator == current_user

        password_record = current_user.password_records.find(params[:password_record_id])
        shared_password_record = SharedPasswordRecord.create!(
          owner: current_user,
          collaborator: collaborator,
          password_record: password_record
        )

        if shared_password_record.persisted? # persisted vs save -> save is for new records, persisted is for existing records
          present shared_password_record, with: Entities::SharedPasswordRecordEntity
        else
          error!("Failed to share password record", 400)
        end
      end

      desc "Get all password records shared with the current user"
      get "shared_with_me" do
        present current_user.received_password_records, with: Entities::SharedPasswordRecordEntity
      end

      desc "Get all password records shared by the current user"
      get "shared_by_me" do
        present current_user.shared_password_records, with: Entities::SharedPasswordRecordEntity
      end

      desc "Remove shared access to a password record"
      params do
        requires :email, type: String, desc: "The email of the user to remove shared access to"
        requires :password_record_id, type: Integer, desc: "The ID of the password record to remove shared access to"
      end
      delete do
        collaborator = User.find_by(email: params[:email])
        password_record = current_user.password_records.find(params[:password_record_id])
        shared_password_record = SharedPasswordRecord.find_by(owner: current_user, collaborator: collaborator, password_record: password_record)
        shared_password_record.destroy
        { message: "Shared access removed with #{collaborator.email} for password record #{password_record.title}" }
      end
    end
  end
end
