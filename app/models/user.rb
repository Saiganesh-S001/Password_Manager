require "securerandom"
require "base64"
require "openssl"

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :password_records, dependent: :destroy

  has_many :owned_shares, class_name: "SharedAccess", foreign_key: "owner_id", dependent: :destroy
  has_many :shared_with, through: :owned_shares, source: :collaborator

  has_many :received_shares, class_name: "SharedAccess", foreign_key: "collaborator_id", dependent: :destroy
  has_many :shared_owners, through: :received_shares, source: :owner

  encrypts :encryption_key, key: -> { Digest::SHA256.digest(Rails.application.secret_key_base) }

  before_create :generate_encryption_key
  before_save :encrypt_encryption_key
  after_find :decrypt_encryption_key

  validates_uniqueness_of :email, :display_name

  validates :email, :display_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :display_name, length: { minimum: 3, maximum: 20 }
  validates :password, length: { minimum: 8 }

  private

  def generate_encryption_key
    self.encryption_key = SecureRandom.hex(16) if encryption_key.blank?
  end

  def encrypt_encryption_key
    return if encryption_key.blank?
    self.encryption_key = encrypt_encryption_key(encryption_key)
  end

  def decrypt_encryption_key
    return if encryption_key.blank?
    self.encryption_key = decrypt_encryption_key(encryption_key)
  end
end
