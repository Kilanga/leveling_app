class CreateUserItems < ActiveRecord::Migration[8.0]
  def change
    create_table :user_items do |t|
      t.references :user, null: false, foreign_key: true
      t.references :shop_item, null: false, foreign_key: true
      t.boolean :active

      t.timestamps
    end
  end
end
