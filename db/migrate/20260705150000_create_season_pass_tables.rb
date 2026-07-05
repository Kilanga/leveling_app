class CreateSeasonPassTables < ActiveRecord::Migration[8.1]
  def change
    create_table :user_season_passes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :season, null: false, foreign_key: true
      t.datetime :premium_purchased_at, null: false
      t.string :transaction_id

      t.timestamps
    end

    add_index :user_season_passes, [ :user_id, :season_id ], unique: true

    create_table :season_pass_claims do |t|
      t.references :user, null: false, foreign_key: true
      t.references :season, null: false, foreign_key: true
      t.integer :tier, null: false
      t.string :track, null: false, default: "free"

      t.timestamps
    end

    add_index :season_pass_claims, [ :user_id, :season_id, :tier, :track ],
      unique: true, name: "index_season_pass_claims_uniqueness"
  end
end
