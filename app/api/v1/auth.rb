module V1
  class Auth < Grape::API
    resource :auth do
      desc "User registration"
      params do
        requires :email, type: String, desc: "Email"
        requires :password, type: String, desc: "Password"
        requires :display_name, type: String, desc: "Display name"
      end
      post :register do
        puts "Hello there from #{@email}"
        user = User.create!(declared(params).merge(password: params[:password])) # here merge is used because params is a hash and we need to merge it with the password
        present user, with: Entities::UserEntity
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
          { token: token }
        else
          error!("Invalid email or password", 401)
        end
      end
    end
  end
end
