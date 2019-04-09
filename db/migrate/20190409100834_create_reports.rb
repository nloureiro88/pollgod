class CreateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :reports do |t|
      t.references :user, foreign_key: true
      t.references :poll, foreign_key: true
      t.string :motive, default: 'improper content'
      t.string :status, default: 'active'

      t.timestamps
    end
  end
end
