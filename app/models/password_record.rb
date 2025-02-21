class PasswordRecord < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged
  belongs_to :user
  include Encryptable

  encrypts :password, key: -> { user.encryption_key }

  before_save :encrypt_password
  after_find :decrypt_password

  scope :for_user, ->(user) {
    where(user_id: user.shared_owners.pluck(:id)).or(where(user_id: user.id))
  }

  scope :accessible_by, ->(user) { # this scope can be used in controllers like PasswordRecord.accessible_by(user)
    where(user_id: user.shared_owners.pluck(:id))
  }

  attr_accessor :password # Virtual attribute to store plaintext password temporarily

  validates :password, :title, :username, :url, presence: true
  validates :title, uniqueness: true

  validates :username, uniqueness: { scope: [ :user_id, :url ] }
  validates :url, format: { with: URI.regexp(%w[http https]), allow_blank: true }
  validates :password, length: { minimum: 8 }
  validates :title, length: { minimum: 3, maximum: 20 }

  def encrypt_password
    return if password.blank?
    self.encrypted_password = encrypt_password(password)
  end

  def decrypt_password
    return if encrypted_password.blank?
    self.password = decrypt_password(encrypted_password)
  end
end
