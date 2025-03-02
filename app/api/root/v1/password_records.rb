module Root
  module V1
    class PasswordRecords < Grape::API
      before { authenticate_user! }
      before { require_verification }

      resource :password_records do
        desc "Get all password records"
        get do
          PasswordRecord.for_user(current_user)
        end

        desc "Show a password record"
        params do
          requires :id, type: Integer, desc: "Password Record ID"
        end
        get ":id" do
          PasswordRecord.find(params[:id])
        end

        desc "Create a password record"
        params do
          requires :title, type: String
          requires :username, type: String
          requires :password, type: String
          optional :url, type: String
        end
        post do
          record = current_user.password_records.create!(declared(params))
          record
        end

        desc "Update a password record"
        params do
          requires :id, type: Integer
          optional :title, type: String
          optional :username, type: String
          optional :password, type: String
          optional :url, type: String
        end
        put ":id" do
          record = PasswordRecord.find(params[:id])
          error!("Unauthorized", 403) unless record.user == current_user
          record.update!(declared(params, include_missing: false))
          record
        end

        desc "Delete a password record"
        params do
          requires :id, type: Integer
        end
        delete ":id" do
          record = PasswordRecord.find(params[:id])
          error!("Unauthorized", 403) unless record.user == current_user
          record.destroy!
          { message: "Deleted successfully" }
        end
      end
    end
  end
end
