require 'securerandom'
require 'base64'
require 'openssl'

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :password_records, dependent: :destroy

  before_create :generate_encryption_key
  before_save :encrypt_encryption_key
  after_find :decrypt_encryption_key

  def generate_encryption_key
    self.encryption_key = SecureRandom.hex(16) if encryption_key.blank? # 16-byte key
  end

  def encrypt_encryption_key
    return if encryption_key.blank?

    cipher = OpenSSL::Cipher.new('AES-256-CBC') # ✅ Consistent with PasswordRecord
    cipher.encrypt
    key = Digest::SHA256.digest(Rails.application.secret_key_base) # Ensure 32-byte key
    cipher.key = key
    iv = cipher.random_iv # 16-byte IV
    encrypted = cipher.update(encryption_key) + cipher.final
    self.encryption_key = Base64.strict_encode64(iv + encrypted)
  end

  def decrypt_encryption_key
    return if encryption_key.blank?

    decipher = OpenSSL::Cipher.new('AES-256-CBC') # ✅ Same as encryption method
    decipher.decrypt
    key = Digest::SHA256.digest(Rails.application.secret_key_base) # Ensure 32-byte key
    decipher.key = key

    encrypted_data = Base64.strict_decode64(encryption_key)
    iv = encrypted_data.byteslice(0, 16) # Extract IV (16 bytes)
    encrypted = encrypted_data.byteslice(16, encrypted_data.length - 16) # Extract encrypted data

    decipher.iv = iv
    self.encryption_key = decipher.update(encrypted) + decipher.final
  rescue => e
    Rails.logger.error "Decryption error: #{e.message}"
    nil
  end
end
