class CreateUserStats < ActiveRecord::Migration[8.0]
  def change
    create_table :user_stats do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.integer :level
      t.integer :xp

      t.timestamps
    end
  end
end
