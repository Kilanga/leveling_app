class CreateExperimentAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :experiment_assignments do |t|
      t.references :user, null: false, foreign_key: true
      t.string :experiment_key, null: false
      t.string :variant, null: false

      t.timestamps
    end

    add_index :experiment_assignments, [ :user_id, :experiment_key ], unique: true
  end
end
