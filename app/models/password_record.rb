class PasswordRecord < ApplicationRecord
  belongs_to :user

  before_save :encrypt_password
  after_find :decrypt_password

  attr_accessor :password # Virtual attribute to store plaintext password temporarily

  def encrypt_password
    return if password.blank?

    cipher = OpenSSL::Cipher.new('AES-256-CBC')
    cipher.encrypt
    key = user.encryption_key
    return if key.blank? # Ensure decrypted key is available

    cipher.key = Digest::SHA256.digest(key) # Ensure 32-byte key
    iv = cipher.random_iv # 16-byte IV

    encrypted = cipher.update(password) + cipher.final
    self.encrypted_password = Base64.strict_encode64(iv + encrypted) # Store IV + encrypted data
  end

  def decrypt_password
    return if encrypted_password.blank?

    decipher = OpenSSL::Cipher.new('AES-256-CBC')
    decipher.decrypt
    key = user.encryption_key
    return if key.blank? # Ensure decrypted key is available

    decipher.key = Digest::SHA256.digest(key) # Ensure 32-byte key

    encrypted_data = Base64.strict_decode64(encrypted_password)
    iv = encrypted_data.byteslice(0, 16) # Extract IV (first 16 bytes)
    encrypted = encrypted_data.byteslice(16, encrypted_data.length - 16) # Extract encrypted data

    decipher.iv = iv
    self.password = decipher.update(encrypted) + decipher.final
  rescue => e
    Rails.logger.error "Password decryption error: #{e.message}"
    self.password = nil
  end
end
