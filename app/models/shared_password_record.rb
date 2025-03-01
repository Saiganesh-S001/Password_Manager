class SharedPasswordRecord < ApplicationRecord
  belongs_to :owner, class_name: "User", foreign_key: "owner_id"
  belongs_to :collaborator, class_name: "User", foreign_key: "collaborator_id"
  belongs_to :password_record, class_name: "PasswordRecord", foreign_key: "password_record_id"

  validates :collaborator_id, uniqueness: { scope: [:owner_id, :password_record_id], message: "Already shared with this user" }
end
