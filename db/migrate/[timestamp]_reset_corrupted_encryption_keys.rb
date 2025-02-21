class ResetCorruptedEncryptionKeys < ActiveRecord::Migration[7.0]
  def up
    User.find_each do |user|
      begin
        # Try to decrypt the key
        encrypted_data = Base64.strict_decode64(user.encryption_key) rescue nil
        next if encrypted_data.nil? || encrypted_data.empty?

        decipher = OpenSSL::Cipher.new("AES-256-CBC")
        decipher.decrypt
        key = Digest::SHA256.digest(Rails.application.secret_key_base)
        decipher.key = key

        iv = encrypted_data.byteslice(0, 16)
        encrypted = encrypted_data.byteslice(16..-1)

        decipher.iv = iv
        decipher.update(encrypted) + decipher.final
      rescue => e
        # If decryption fails, reset the encryption key
        puts "Resetting encryption key for User #{user.id}"
        user.update_column(:encryption_key, nil)
        user.generate_encryption_key
        user.encrypt_encryption_key
        user.save(validate: false)
      end
    end
  end

  def down
    # This migration cannot be reversed
  end
end
