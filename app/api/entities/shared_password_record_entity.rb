module Entities
  class SharedPasswordRecordEntity < Grape::Entity
    expose :owner, using: Entities::UserEntity
    expose :collaborator, using: Entities::UserEntity
    expose :password_record, using: Entities::PasswordRecordEntity
    expose :created_at
    expose :updated_at
  end
end
