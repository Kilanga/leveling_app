class CreateWeeklyQuests < ActiveRecord::Migration[8.0]
  def change
    create_table :weekly_quests do |t|
      t.string :title, null: false
      t.text :description
      t.integer :xp_reward, default: 300
      t.references :category, null: false, foreign_key: true
      t.datetime :valid_until

      t.timestamps
    end
  end
end
