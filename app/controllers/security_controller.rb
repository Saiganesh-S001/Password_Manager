class SecurityController < ApplicationController
  before_action :authenticate_user!

  def verify
  end

  def check
    if current_user.valid_password?(params[:password])
      session[:verified] = true
      redirect_to password_records_path, notice: "Verification successful."
    else
      redirect_to verify_security_path, alert: "Incorrect password."
    end
  end
end
