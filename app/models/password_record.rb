class PasswordRecord < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged
  belongs_to :user

  has_many :shared_password_records, dependent: :destroy # this will delete the shared_password_records when the password_record is deleted

  before_save :encrypt_password
  after_find :decrypt_password

  def encrypt_password
    return unless password.present?

    encryptor = ActiveSupport::MessageEncryptor.new(encryption_key_for_record)
    self.password = encryptor.encrypt_and_sign(password)
  end

  def decrypt_password
    self.password = decrypted_password
  end

  def decrypted_password
    return unless password.present?

    encryptor = ActiveSupport::MessageEncryptor.new(encryption_key_for_record)
    encryptor.decrypt_and_verify(password)
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    nil # Handle invalid decryption
  end


  scope :for_user, ->(user) {
    where(user_id: user.shared_owners.pluck(:id))
      .or(where(id: user.received_password_records.pluck(:password_record_id)))
  }

  scope :real_accessible_by, ->(user) {
    where(user_id: user.shared_owners.pluck(:id)).
      or(where(user_id: user.id))
  }

  scope :accessible_by, ->(user) { # this scope can be used in controllers like PasswordRecord.accessible_by(user)
    where(user_id: user.shared_owners.pluck(:id))
  }


  validates :password, :title, :username, :url, presence: true
  validates :title, presence: true, uniqueness: true
  validates :username, uniqueness: { scope: [ :user_id, :url ] }
  validates :url, format: { with: URI.regexp(%w[http https]), allow_blank: true }
  validates :password, length: { minimum: 8 }, allow_nil: true # allow_nil allows updates without requiring new password
  validates :title, length: { minimum: 3, maximum: 20 }

  private

  def encryption_key_for_record
    secret_key = "#{Rails.application.credentials.active_record_encryption[:primary_key]}#{user.encryption_key}"
    key = Digest::SHA256.digest(secret_key) # Convert to a valid 32-byte key
    key
  end
end
