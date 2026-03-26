class AddRarityAndIsFreeToBadge < ActiveRecord::Migration[8.1]
  def change
    add_column :badges, :rarity, :string, default: "rare", comment: "rare, epic, legendary"
    add_column :badges, :is_free, :boolean, default: false, comment: "Free badge unlockable via achievements"
  end
end
