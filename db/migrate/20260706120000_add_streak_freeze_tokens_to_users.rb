class AddStreakFreezeTokensToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :streak_freeze_tokens, :integer, default: 0, null: false
  end
end
