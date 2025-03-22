class AddColumnToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :is_created_by_admin, :boolean, default: false, null: false
  end
end
