class SecurityController < ApplicationController
  before_action :authenticate_user!

  def reset_verification
    session[:verified] = nil
    session.delete(:verified_at)
    Rails.logger.info "Session after reset: #{session.to_hash}"
    head :ok
  end
  def verify
  end

  def check
    if current_user.valid_password?(params[:password])
      session[:verified] = true
      session[:verified_at] = Time.now
      redirect_to password_records_path, notice: "Verification successful."
    else
      redirect_to verify_security_path, alert: "Incorrect password."
    end
  end
end


