module Root
  module V1
    class Security < Grape::API
      resource :security do
        desc "Reset verification"
        delete :reset_verification do
          session[:verified] = nil
          session.delete(:verified_at)
          { message: "Verification reset" }
        end

        desc "Verify user"
        params do
          requires :password, type: String
        end
        post :verify do
          if current_user.valid_password?(params[:password])
            session[:verified] = true
            session[:verified_at] = Time.now
            { message: "Verification successful" }
          else
            error!("Incorrect password", 401)
          end
        end
      end
    end
  end
end
