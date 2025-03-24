module V1
  class Auth < Grape::API
    rescue_from ActiveRecord::RecordNotFound do |e|
      Rails.logger.error("Record not found: #{e.message}")
      error!({ error: e.message }, 404)
    end

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      Rails.logger.error("Validation errors: #{e.full_messages}")
      error!({ error: e.full_messages }, 400)
    end

    rescue_from :all do |e|
      Rails.logger.error("Internal server error: #{e.message}")
      error!({ error: e.message }, 500)
    end

    helpers do
      def authenticate_user!
        token = headers["Authorization"]&.split(" ")&.last
        error!("Unauthorized", 401) unless token
        begin
          payload = Warden::JWTAuth::TokenDecoder.new.call(token)
          @current_user = User.find_by(jti: payload["jti"])
          error!("Unauthorized", 401) unless @current_user
        rescue JWT::DecodeError
          error!("Unauthorized", 401)
        end
      end

      def current_user
        @current_user
      end
    end

    resource :auth do
      desc "User registration"
      params do
        requires :email, type: String, desc: "Email"
        requires :password, type: String, desc: "Password"
        requires :display_name, type: String, desc: "Display name"
      end
      post :register do
        puts "params: #{params}"
        user = User.create!(declared(params).merge(password: params[:password])) # here merge is used because params is a hash and we need to merge it with the password
        if user.persisted?
          token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
          present :user, user, with: Entities::UserEntity
          present :token, token
        else
          error!(user.errors.full_messages, 422)
        end
      end

      desc "User login"
      params do
        requires :email, type: String, desc: "Email"
        requires :password, type: String, desc: "Password"
      end
      post :login do
        user = User.find_by(email: params[:email])
        if user&.valid_password?(params[:password])
          # token  = Warden::JWTAuth::TokenEncoder.new.call(user.jti) # here we are encoding the user's jti to a token
          token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
          present :user, user, with: Entities::UserEntity
          present :token, token
        else
          error!("Invalid email or password", 401)
        end
      end

      desc "User update"
      params do
        optional :email, type: String, desc: "Email"
        optional :password, type: String, desc: "Password"
        requires :current_password, type: String, desc: "Current password"
        optional :display_name, type: String, desc: "Display name"
      end
      put :update do
        authenticate_user!

        unless current_user.valid_password?(params[:current_password])
          error!({ error: "Invalid current password" }, 401)
        end

        update_params = {}
        update_params[:email] = params[:email] if params[:email].present?
        update_params[:password] = params[:password] if params[:password].present?
        update_params[:display_name] = params[:display_name] if params[:display_name].present?

        if current_user.update(update_params)
          present :user, current_user, with: Entities::UserEntity
        else
          error!(current_user.errors.full_messages, 422)
        end
      end

      desc "User logout"
      post :logout do
        authenticate_user!
        current_user.update(jti: SecureRandom.uuid)
        status 204
        { message: "User logged out successfully" }
      end

      desc "User delete"
      delete :delete do
        authenticate_user!
        if current_user.valid_password?(params[:current_password])
          current_user.destroy
          status 204
          { message: "User deleted successfully" }
        else
          error!({ error: "Invalid current password" }, 401)
        end
      end
    end
  end
end
