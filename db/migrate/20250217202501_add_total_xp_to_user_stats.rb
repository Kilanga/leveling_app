class AddTotalXpToUserStats < ActiveRecord::Migration[8.0]
  def change
    add_column :user_stats, :total_xp, :integer, default: 0
  end
end
