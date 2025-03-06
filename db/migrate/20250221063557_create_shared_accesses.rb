class CreateSharedAccesses < ActiveRecord::Migration[8.0]
  def change
    create_table :shared_accesses do |t|
      t.integer :owner_id
      t.integer :collaborator_id

      t.timestamps
    end
  end
end
