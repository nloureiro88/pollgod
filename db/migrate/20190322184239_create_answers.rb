class CreateAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :answers do |t|
      t.references :user, foreign_key: true
      t.references :poll, foreign_key: true
      t.integer :points
      t.string :answer
      t.boolean :f_love, default: false
      t.boolean :f_funny, default: false
      t.boolean :f_interest, default: false
      t.string :status, default: "active"

      t.timestamps
    end
  end
end
