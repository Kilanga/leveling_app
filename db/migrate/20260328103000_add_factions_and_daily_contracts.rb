class AddFactionsAndDailyContracts < ActiveRecord::Migration[8.0]
  def change
    create_table :factions do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :color_hex, null: false

      t.timestamps
    end
    add_index :factions, :slug, unique: true

    add_reference :users, :faction, foreign_key: true

    create_table :faction_influences do |t|
      t.references :faction, null: false, foreign_key: true
      t.date :on_date, null: false
      t.integer :points, null: false, default: 0

      t.timestamps
    end
    add_index :faction_influences, [ :faction_id, :on_date ], unique: true

    create_table :daily_contracts do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.integer :target_count, null: false
      t.integer :reward_coins, null: false
      t.string :risk_tier, null: false
      t.date :active_on, null: false

      t.timestamps
    end
    add_index :daily_contracts, :active_on

    create_table :user_daily_contracts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :daily_contract, null: false, foreign_key: true
      t.string :status, null: false, default: "offered"
      t.integer :progress_count, null: false, default: 0
      t.datetime :accepted_at
      t.datetime :completed_at
      t.datetime :reward_claimed_at

      t.timestamps
    end
    add_index :user_daily_contracts, [ :user_id, :daily_contract_id ], unique: true
  end
end
