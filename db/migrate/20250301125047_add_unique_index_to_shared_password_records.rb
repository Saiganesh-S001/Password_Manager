class AddUniqueIndexToSharedPasswordRecords < ActiveRecord::Migration[8.0]
  def change
    def change
      add_index :shared_password_records, [:owner_id, :collaborator_id, :password_record_id], unique: true, name: "index_shared_passwords_on_owner_collab_record"
    end
  end
end
