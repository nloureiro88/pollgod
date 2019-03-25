class AddColumnsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :photo, :string
    add_column :users, :gender, :string
    add_column :users, :birthdate, :date
    add_column :users, :location, :text
    add_column :users, :profession, :string
    add_column :users, :hobbies, :string, array: true, default: []
    add_column :users, :subscription, :string, default: 'free'
    add_column :users, :status, :string, default: 'active'
  end
end
