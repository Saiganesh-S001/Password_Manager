module Encryptable
  extend ActiveSupport::Concern

  class_methods do
    def encrypts(*attributes, key: nil)
      attributes.each do |attribute|
        define_method("encrypt_#{attribute}") do |value|
          encrypt_value(value, encryption_key_for(key))
        end

        define_method("decrypt_#{attribute}") do |value|
          decrypt_value(value, encryption_key_for(key))
        end
      end
    end
  end

  private

  def encryption_key_for(key)
    key.is_a?(Proc) ? instance_exec(&key) : send(key)
  end

  def encrypt_value(value, key)
    return if value.blank? || key.blank?

    begin
      cipher = OpenSSL::Cipher.new("AES-256-CBC")
      cipher.encrypt
      cipher.key = Digest::SHA256.digest(key)
      iv = cipher.random_iv

      padded_data = add_padding(value)
      encrypted = cipher.update(padded_data) + cipher.final

      Base64.strict_encode64(iv + encrypted)
    rescue OpenSSL::Cipher::CipherError => e
      Rails.logger.error "Encryption error: #{e.message}"
      raise "Failed to encrypt value"
    end
  end

  def decrypt_value(value, key)
    return if value.blank? || key.blank?

    begin
      decipher = OpenSSL::Cipher.new("AES-256-CBC")
      decipher.decrypt
      decipher.key = Digest::SHA256.digest(key)

      encrypted_data = Base64.strict_decode64(value)
      return if encrypted_data.length < 16

      iv = encrypted_data.byteslice(0, 16)
      encrypted = encrypted_data.byteslice(16..-1)
      return if encrypted.nil? || encrypted.empty?

      decipher.iv = iv
      decrypted = decipher.update(encrypted) + decipher.final

      remove_padding(decrypted)
    rescue OpenSSL::Cipher::CipherError => e
      Rails.logger.error "Decryption error: #{e.message}"
      nil
    end
  end

  def add_padding(value)
    padding_length = 16 - (value.length % 16)
    value + (padding_length.chr * padding_length)
  end

  def remove_padding(value)
    padding_length = value[-1].ord
    padding_length < 16 ? value[0...-padding_length] : value
  end
end
