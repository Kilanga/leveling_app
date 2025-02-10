class CreateQuests < ActiveRecord::Migration[8.0]
  def change
    create_table :quests do |t|
      t.string :title
      t.text :description
      t.integer :xp
      t.references :category, null: false, foreign_key: true
      t.datetime :valid_until

      t.timestamps
    end
  end
end
