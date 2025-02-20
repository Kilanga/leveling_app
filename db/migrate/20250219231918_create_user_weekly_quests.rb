class CreateUserWeeklyQuests < ActiveRecord::Migration[8.0]
  def change
    create_table :user_weekly_quests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :weekly_quest, null: false, foreign_key: true
      t.boolean :completed, default: false

      t.timestamps
    end
  end
end