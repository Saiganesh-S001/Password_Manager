class CreatePasswordRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :password_records do |t|
      t.string :username
      t.string :password
      t.string :url
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
