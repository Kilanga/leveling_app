class CreateFriendChallenges < ActiveRecord::Migration[8.1]
  def change
    create_table :friend_challenges do |t|
      t.references :challenger, null: false, foreign_key: { to_table: :users }
      t.references :challenged, null: false, foreign_key: { to_table: :users }
      t.references :winner, foreign_key: { to_table: :users }
      t.string :status, null: false, default: "pending"
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.integer :reward_coins, null: false, default: 50
      t.integer :challenger_xp_gain, null: false, default: 0
      t.integer :challenged_xp_gain, null: false, default: 0

      t.timestamps
    end

    add_index :friend_challenges, [ :challenger_id, :challenged_id, :status ], name: "index_friend_challenges_on_pair_and_status"
  end
end
