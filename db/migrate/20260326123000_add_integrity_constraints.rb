class AddIntegrityConstraints < ActiveRecord::Migration[8.0]
  def up
    execute "UPDATE user_stats SET level = 1 WHERE level IS NULL OR level < 1"
    execute "UPDATE user_stats SET xp = 0 WHERE xp IS NULL OR xp < 0"
    execute "UPDATE user_stats SET total_xp = 0 WHERE total_xp IS NULL OR total_xp < 0"

    change_column_default :user_stats, :level, from: nil, to: 1
    change_column_default :user_stats, :xp, from: nil, to: 0
    change_column_default :user_stats, :total_xp, from: nil, to: 0

    change_column_null :user_stats, :level, false
    change_column_null :user_stats, :xp, false
    change_column_null :user_stats, :total_xp, false

    execute "UPDATE friendships SET status = 'pending' WHERE status IS NULL"
    change_column_default :friendships, :status, from: nil, to: "pending"
    change_column_null :friendships, :status, false

    execute "DELETE FROM friendships WHERE user_id = friend_id"

    add_index :user_stats, [ :user_id, :category_id ], unique: true, if_not_exists: true
    add_index :user_quests, [ :user_id, :quest_id ], unique: true, if_not_exists: true
    add_index :user_items, [ :user_id, :shop_item_id ], unique: true, if_not_exists: true
    add_index :friendships, [ :user_id, :friend_id ], unique: true, if_not_exists: true

    add_check_constraint :friendships, "user_id <> friend_id", name: "friendships_user_not_self", if_not_exists: true
  end

  def down
    remove_check_constraint :friendships, name: "friendships_user_not_self", if_exists: true

    remove_index :friendships, column: [ :user_id, :friend_id ], if_exists: true
    remove_index :user_items, column: [ :user_id, :shop_item_id ], if_exists: true
    remove_index :user_quests, column: [ :user_id, :quest_id ], if_exists: true
    remove_index :user_stats, column: [ :user_id, :category_id ], if_exists: true

    change_column_null :friendships, :status, true
    change_column_default :friendships, :status, from: "pending", to: nil

    change_column_null :user_stats, :total_xp, true
    change_column_null :user_stats, :xp, true
    change_column_null :user_stats, :level, true

    change_column_default :user_stats, :total_xp, from: 0, to: nil
    change_column_default :user_stats, :xp, from: 0, to: nil
    change_column_default :user_stats, :level, from: 1, to: nil
  end
end
