class AddJtiToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :jti, :string

    User.reset_column_information
    User.find_each do |user|
      user.update_column :jti, SecureRandom.uuid
    end

    change_column_null :users, :jti, false
    add_index :users, :jti, unique: true
  end

  def down
    remove_index :users, :jti
    remove_column :users, :jti
  end
end
