module Root
  module V1
    class Base < Grape::API
      version "v1", using: :path
      format :json

      mount Root::V1::PasswordRecords
      mount Root::V1::Security
      mount Root::V1::SharedAccess
    end
  end
end
