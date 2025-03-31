class AddItemTypeToShopItems < ActiveRecord::Migration[8.0]
  def change
    add_column :shop_items, :item_type, :string unless column_exists?(:shop_items, :item_type)
  end
end
