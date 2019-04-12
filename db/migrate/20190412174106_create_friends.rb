class CreateFriends < ActiveRecord::Migration[5.2]
  def change
    create_table :friends do |t|
      t.integer :active_user_id, foreign_key: true
      t.integer :follow_user_id, foreign_key: true
      t.string :status, default: 'active'

      t.timestamps
    end
  end
end
