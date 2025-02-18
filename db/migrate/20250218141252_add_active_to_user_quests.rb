class AddActiveToUserQuests < ActiveRecord::Migration[8.0]
  def change
    add_column :user_quests, :active, :boolean
  end
end
