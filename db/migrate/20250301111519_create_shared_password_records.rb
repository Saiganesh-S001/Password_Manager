class CreateSharedPasswordRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :shared_password_records do |t|
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.references :collaborator, null: false, foreign_key: { to_table: :users }
      t.references :password_record, null: false, foreign_key: { to_table: :password_records }

      t.timestamps
    end
    add_index :shared_password_records, [:owner_id, :collaborator_id, :password_record_id], unique: true, name: "index_shared_passwords_on_owner_collab_record"
  end
end
