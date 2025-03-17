module V1
  class PasswordRecords < Grape::API
    rescue_from ActiveRecord::RecordNotFound do |e|
      error!({ error: e.message }, 404)
    end

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      error!({ error: e.full_messages }, 400)
    end

    rescue_from :all do |e|
      error!({ error: e.message }, 500)
    end

    helpers do
      def authenticate_user!
        token = headers["Authorization"]&.split(" ")&.last
        error!("Unauthorized", 401) unless token


        payload = Warden::JWTAuth::TokenDecoder.new.call(token)
        puts "payload: #{payload}"
        @current_user = User.find_by(jti: payload["jti"])

        error!("Unauthorized", 401) unless @current_user
      end

      def current_user
        @current_user
      end
    end

    before do
      authenticate_user!
    end

    resource :password_records do
      desc "Get all password records"
      params do
        optional :search_by_title, type: String, desc: "Search by title"
        optional :search_by_username, type: String, desc: "Search by username"
        optional :search_by_url, type: String, desc: "Search by url"
      end
      get do
        search_title = params[:search_by_title]&.strip&.downcase
        search_username = params[:search_by_username]&.strip&.downcase
        search_url = params[:search_by_url]&.strip&.downcase

        base_query = PasswordRecord.for_user(current_user)

        records_made_by_current_user = current_user.password_records.order(created_at: :desc)
        records_shared_with_current_user = base_query.where.not(user_id: current_user.id).order(updated_at: :desc)

       if params[:search_by_title].present? || params[:search_by_username].present? || params[:search_by_url].present?
         conditions = []
         conditions << PasswordRecord.arel_table[:title].matches("%#{search_title}%") if search_title.present?
         conditions << PasswordRecord.arel_table[:username].matches("%#{search_username}%") if search_username.present?
         conditions << PasswordRecord.arel_table[:url].matches("%#{search_url}%") if search_url.present?

         search_condition = conditions.inject(&:and)

         records_made_by_current_user = records_made_by_current_user.where(search_condition)
         records_shared_with_current_user = records_shared_with_current_user.where(search_condition)
       end

        all_records = {
          owner_records: records_made_by_current_user,
          shared_records: records_shared_with_current_user
        }

        puts "all_records: #{all_records}"

        present :owner_records, records_made_by_current_user, with: Entities::PasswordRecordEntity
        present :shared_records, records_shared_with_current_user, with: Entities::PasswordRecordEntity
      end


      desc "Create a password record"
      params do
        requires :title, type: String, desc: "Title"
        requires :password, type: String, desc: "Password"
        requires :url, type: String, desc: "URL"
        requires :username, type: String, desc: "Username"
      end
      post do
          record = current_user.password_records.create!(declared(params))
          present record, with: Entities::PasswordRecordEntity
      end

      route_param :id do
        desc "Get a password record"
        get do
          record = PasswordRecord.find(params[:id])
          puts "record: #{record}"
          present record, with: Entities::PasswordRecordEntity
        end

        desc "Update a password record"
        params do
          requires :title, type: String, desc: "Title"
          requires :password, type: String, desc: "Password"
          requires :url, type: String, desc: "URL"
          requires :username, type: String, desc: "Username"
        end
        put do
          record = PasswordRecord.find(params[:id])
          if record.user_id != current_user.id
            error!("Unauthorized", 401)
          end
          puts declared(params)
          record.update!(declared(params))
          present record, with: Entities::PasswordRecordEntity
        end

        desc "Delete a password record"
        delete do
          record = PasswordRecord.find(params[:id])
          if record.user_id != current_user.id
            error!("Unauthorized", 401)
          end
          record.destroy
          present record, with: Entities::PasswordRecordEntity
        end
      end
    end
  end
end
