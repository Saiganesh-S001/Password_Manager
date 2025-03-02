module Root
  module V1
    class SharedAccess < Grape::API
      resource :shared_access do
        desc 'Share access with another user'
        params do
          requires :email, type: String
          optional :password_record_id, type: Integer
        end
        post do
          collaborator = User.find_by(email: params[:email])
          error!('Invalid user', 400) unless collaborator && collaborator != current_user

          shared_access = if params[:password_record_id].present?
                            current_user.shared_password_records.create(collaborator: collaborator, password_record_id: params[:password_record_id])
                          else
                            current_user.owned_shares.create(collaborator: collaborator)
                          end

          if shared_access.persisted?
            { message: "Access shared with #{collaborator.email}" }
          else
            error!(shared_access.errors.full_messages.join(", "), 422)
          end
        end

        desc 'Remove shared access'
        params do
          requires :id, type: Integer
          optional :password_record_id, type: Integer
        end
        delete ':id' do
          shared_access = if params[:password_record_id].present?
                            SharedPasswordRecord.find_by(owner: current_user, collaborator_id: params[:id], password_record_id: params[:password_record_id])
                          else
                            current_user.owned_shares.find_by(collaborator_id: params[:id])
                          end
          shared_access&.destroy
          { message: 'Access removed' }
        end
      end
    end
  end
end
