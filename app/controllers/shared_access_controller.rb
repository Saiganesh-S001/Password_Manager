class SharedAccessController < ApplicationController
  before_action :authenticate_user!

  def create
    collaborator = User.find_by(email: params[:email])
    if collaborator && collaborator != current_user
      shared_access = current_user.owned_shares.create(collaborator: collaborator)
      if shared_access.persisted?
        redirect_to password_records_path, notice: "Access shared with #{collaborator.email}."
      else
        redirect_to password_records_path, alert: shared_access.errors.full_messages.join(", ")
      end
    else
      redirect_to password_records_path, alert: "Invalid user."
    end
  end

  def destroy
    shared_access = current_user.owned_shares.find_by(collaborator_id: params[:id])
    shared_access&.destroy
    redirect_to password_records_path, notice: "Access removed."
  end
end
