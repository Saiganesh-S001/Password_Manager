class SharedAccessController < ApplicationController
  before_action :authenticate_user!

  def create
    collaborator = User.find_by(email: params[:email])
    redirect_to password_records_path, alert: "Invalid user" if collaborator.nil? || collaborator == current_user

    # particular password record
    if params[:password_record_id].present?
      password_record = current_user.password_records.find_by(id: params[:password_record_id])
      shared_access = SharedPasswordRecord.create(owner: current_user, collaborator: collaborator, password_record: password_record)
    else
      SharedPasswordRecord.where(owner: current_user, collaborator: collaborator).destroy_all # destroy existing sharing
      shared_access = current_user.password_records.map do |password_record|
        SharedPasswordRecord.create(owner: current_user, collaborator: collaborator, password_record: password_record)
      end
    end

    if shared_access.all?(&:persisted?)
      redirect_to password_records_path, notice: "Access shared with #{collaborator.email}."
    else
      redirect_to password_records_path, alert: shared_access.map(&:errors).flatten.join(", ")
    end
  end

  def destroy
    if params[:password_record_id].present?
      shared_access = SharedPasswordRecord.find_by(owner: current_user, collaborator_id: params[:id], password_record_id: params[:password_record_id])
      shared_access.destroy
    else # remove full access
      shared_full_access = SharedAccess.find_by(owner: current_user, collaborator_id: params[:id])
      shared_full_access&.destroy
      shared_access_array = SharedPasswordRecord.where(owner: current_user, collaborator_id: params[:id]).pluck(:id)
      if shared_access_array.nil?
        redirect_to password_records_path, alert: "No shared password records found."
      else
        shared_access_array.each do |shared_access_id|
          shared_access = SharedPasswordRecord.find(shared_access_id)
          shared_access.destroy
        end
      end
    end
    redirect_to password_records_path, notice: "Access removed."
  end
end
