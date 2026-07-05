class CreateSeasons < ActiveRecord::Migration[8.1]
  def change
    create_table :seasons do |t|
      t.integer :number, null: false
      t.string :name, null: false
      t.date :starts_on, null: false
      t.date :ends_on, null: false
      t.datetime :closed_at

      t.timestamps
    end

    add_index :seasons, :number, unique: true
    add_index :seasons, [ :starts_on, :ends_on ]

    create_table :user_seasons do |t|
      t.references :user, null: false, foreign_key: true
      t.references :season, null: false, foreign_key: true
      t.integer :xp, null: false, default: 0

      t.timestamps
    end

    add_index :user_seasons, [ :season_id, :user_id ], unique: true
    add_index :user_seasons, [ :season_id, :xp ]
  end
end
