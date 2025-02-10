class CreateUserQuests < ActiveRecord::Migration[8.0]
  def change
    create_table :user_quests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :quest, null: false, foreign_key: true
      t.integer :progress
      t.boolean :completed

      t.timestamps
    end
  end
end
