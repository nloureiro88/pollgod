class CreatePolls < ActiveRecord::Migration[5.2]
  def change
    create_table :polls do |t|
      t.references :user, foreign_key: true
      t.references :category, foreign_key: true
      t.integer :t_likes
      t.integer :t_love
      t.integer :t_funny
      t.integer :t_interest
      t.integer :points
      t.string :qtype
      t.text :question
      t.string :optype
      t.text :options, array: true, default: []
      t.string :tags, array: true, default: []
      t.string :image
      t.datetime :deadline
      t.string :status, default: "active"

      t.timestamps
    end
  end
end
