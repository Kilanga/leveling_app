class AddCompletedCountToUserQuests < ActiveRecord::Migration[8.0]
  def change
    add_column :user_quests, :completed_count, :integer, default: 0
  end
end
