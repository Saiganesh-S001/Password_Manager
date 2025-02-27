class PasswordRecord < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged
  belongs_to :user


  encrypts :password

  scope :for_user, ->(user) {
    where(user_id: user.shared_owners.pluck(:id)).or(where(user_id: user.id))
  }

  scope :accessible_by, ->(user) { # this scope can be used in controllers like PasswordRecord.accessible_by(user)
    where(user_id: user.shared_owners.pluck(:id))
  }


  validates :password, :title, :username, :url, presence: true
  validates :title, presence: true, uniqueness: true
  validates :username, uniqueness: { scope: [ :user_id, :url ] }
  validates :url, format: { with: URI.regexp(%w[http https]), allow_blank: true }
  validates :password, length: { minimum: 8 }
  validates :title, length: { minimum: 3, maximum: 20 }
end
