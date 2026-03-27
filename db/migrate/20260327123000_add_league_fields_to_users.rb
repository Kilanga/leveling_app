class AddLeagueFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :league_tier, :integer, default: 1, null: false
    add_column :users, :league_last_settled_week, :date
    add_column :users, :league_last_move, :integer, default: 0, null: false
  end
end
