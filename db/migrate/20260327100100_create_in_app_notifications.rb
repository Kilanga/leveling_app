class CreateInAppNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :in_app_notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :kind, null: false
      t.string :title, null: false
      t.text :body
      t.string :cta_path
      t.datetime :read_at

      t.timestamps
    end

    add_index :in_app_notifications, [:user_id, :created_at]
    add_index :in_app_notifications, [:user_id, :read_at]
  end
end
