class AddBossRewardedAtToFactionInfluences < ActiveRecord::Migration[8.1]
  def change
    add_column :faction_influences, :boss_rewarded_at, :datetime
  end
end
