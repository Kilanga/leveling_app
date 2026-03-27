class AddCosmeticSelectionsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :active_profile_frame_id, :bigint
    add_column :users, :active_xp_theme_id, :bigint
    add_column :users, :active_profile_card_id, :bigint
    add_column :users, :profile_card_custom_text, :string, limit: 100

    add_index :users, :active_profile_frame_id
    add_index :users, :active_xp_theme_id
    add_index :users, :active_profile_card_id

    add_foreign_key :users, :shop_items, column: :active_profile_frame_id
    add_foreign_key :users, :shop_items, column: :active_xp_theme_id
    add_foreign_key :users, :shop_items, column: :active_profile_card_id
  end
end
