class SharedAccessController < ApplicationController
  before_action :authenticate_user!

  def create
    collaborator = User.find_by(email: params[:email])
    if collaborator && collaborator != current_user
      if params[:password_record_id].present?
        password_record_id = params[:password_record_id]
        password_record = current_user.password_records.find_by(id: password_record_id)
        shared_access = SharedPasswordRecord.create(owner: current_user, collaborator: collaborator, password_record: password_record)
      else # share all passwords
        shared_access = current_user.owned_shares.create(collaborator: collaborator)
      end

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
    if params[:password_record_id].present?
      shared_access = SharedPasswordRecord.find_by(owner: current_user, collaborator_id: params[:id], password_record_id: params[:password_record_id])
    else # remove full access
      shared_access = current_user.owned_shares.find_by(collaborator_id: params[:id])
    end
    shared_access&.destroy
    redirect_to password_records_path, notice: "Access removed."
  end
end
