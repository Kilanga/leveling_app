class AddDifficultyToQuests < ActiveRecord::Migration[8.1]
  def change
    add_column :quests, :difficulty, :string, null: false, default: "E"
    add_index :quests, :difficulty
  end
end
