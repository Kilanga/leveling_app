class AddFactionContributions < ActiveRecord::Migration[8.0]
  def change
    create_table :faction_contributions do |t|
      t.references :faction, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.date :on_date, null: false
      t.integer :points, null: false, default: 0

      t.timestamps
    end

    add_index :faction_contributions, [ :faction_id, :user_id, :on_date ], unique: true, name: "index_faction_contrib_on_faction_user_cycle"
  end
end
