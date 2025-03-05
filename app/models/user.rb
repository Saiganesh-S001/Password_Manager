require "securerandom"
require "base64"
require "openssl"

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  include Devise::JWT::RevocationStrategies::JTIMatcher # for jwt_revocation_strategy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self # self is the class itself (User)
  has_many :password_records, dependent: :destroy
  before_create :generate_encryption_key
  before_validation :ensure_encryption_key

  # Sharing all the password_records
  has_many :owned_shares, class_name: "SharedAccess", foreign_key: "owner_id", dependent: :destroy
  has_many :shared_with, through: :owned_shares, source: :collaborator

  has_many :received_shares, class_name: "SharedAccess", foreign_key: "collaborator_id", dependent: :destroy
  has_many :shared_owners, through: :received_shares, source: :owner

  # Sharing only specific password_records
  has_many :shared_password_records, class_name: "SharedPasswordRecord", foreign_key: "owner_id", dependent: :destroy
  has_many :shared_passwords, through: :shared_password_records, source: :password_record, dependent: :destroy

  has_many :received_password_records, class_name: "SharedPasswordRecord", foreign_key: "collaborator_id", dependent: :destroy
  has_many :received_passwords, through: :received_password_records, source: :password_record, dependent: :destroy


  validates_uniqueness_of :email, :display_name

  validates :email, :display_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :encrypted_password, length: { minimum: 8 }
  validates :encryption_key, presence: true

  def generate_encryption_key
    self.encryption_key = SecureRandom.hex(32)
  end

  def ensure_encryption_key
    self.encryption_key ||= SecureRandom.hex(32)
  end

  def encrypt_password(password)
    cipher = OpenSSL::Cipher.new("AES-256-CBC")
    cipher.encrypt
    cipher.key = self.encryption_key
    cipher.update(password) + cipher.final
  end

  def decrypt_password(encrypted_password)
    cipher = OpenSSL::Cipher.new("AES-256-CBC")
    cipher.decrypt
    cipher.key = self.encryption_key
    cipher.update(encrypted_password) + cipher.final
  end
end
