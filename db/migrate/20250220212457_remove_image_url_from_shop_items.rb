class RemoveImageUrlFromShopItems < ActiveRecord::Migration[8.0]
  def change
    remove_column :shop_items, :image_url, :string if column_exists?(:shop_items, :image_url)
  end
end
