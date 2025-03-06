class SharedAccess < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  belongs_to :collaborator, class_name: 'User'

  validates :collaborator_id, uniqueness: { scope: :owner_id , message: "There is already a collaborator for you"}
end
