class AddEncryptedPasswordToPasswordRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :password_records, :encrypted_password, :string
  end
end
