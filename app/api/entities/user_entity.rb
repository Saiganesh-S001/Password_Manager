module Entities
  class UserEntity < Grape::Entity
    expose :id
    expose :email
    expose :display_name
  end
end
