class CreateFilters < ActiveRecord::Migration[5.2]
  def change
    create_table :filters do |t|
      t.references :user, foreign_key: true
      t.references :category, foreign_key: true
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
