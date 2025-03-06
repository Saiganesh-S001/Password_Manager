class AddSlugToPasswordRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :password_records, :slug, :string
    add_index :password_records, :slug, unique: true
  end
end
