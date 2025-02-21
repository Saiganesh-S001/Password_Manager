class AddTitleToPasswordRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :password_records, :title, :string
  end
end
