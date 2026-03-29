class CreateProductEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :product_events do |t|
      t.references :user, foreign_key: true
      t.string :event_name, null: false
      t.text :metadata_json, null: false, default: "{}"

      t.timestamps
    end

    add_index :product_events, [ :event_name, :created_at ]
    add_index :product_events, [ :user_id, :event_name, :created_at ]
  end
end
