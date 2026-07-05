class CreateSystemQuestAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :system_quest_assignments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :quest, null: false, foreign_key: true
      t.date :assigned_on, null: false
      t.datetime :completed_at

      t.timestamps
    end

    add_index :system_quest_assignments, [ :user_id, :quest_id, :assigned_on ],
      unique: true, name: "index_system_assignments_uniqueness"
    add_index :system_quest_assignments, [ :user_id, :assigned_on ]

    add_column :users, :last_perfect_day_on, :date
  end
end
