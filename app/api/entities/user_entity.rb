module Entities
  class UserEntity < Grape::Entity
    expose :id
    expose :email
    expose :display_name
    expose :created_at
    expose :updated_at
  end
end
