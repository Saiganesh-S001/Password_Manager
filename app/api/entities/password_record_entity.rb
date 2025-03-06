module Entities
  class PasswordRecordEntity < Grape::Entity
    expose :id
    expose :title
    expose :username
    expose :url
    expose :created_at
    expose :updated_at
    expose :user, using: Entities::UserEntity
  end
end
