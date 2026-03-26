class AddActiveAvatarItemToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :active_avatar_item, foreign_key: { to_table: :shop_items }
  end
end
