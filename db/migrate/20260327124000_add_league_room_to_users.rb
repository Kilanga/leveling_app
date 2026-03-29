class AddLeagueRoomToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :league_room, :integer, default: 1, null: false
    add_index :users, [ :league_tier, :league_room ], name: "index_users_on_league_tier_and_league_room"
  end
end
