module Entities
  class GroupPasswordRecordEntity < Grape::Entity
    expose :owner_records, using: Entities::PasswordRecordEntity
    expose :shared_records, using: Entities::SharedPasswordRecordEntity, if: { shared_records: true }
    expose :received_records, using: Entities::PasswordRecordEntity
  end
end
