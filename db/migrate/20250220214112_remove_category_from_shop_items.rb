class RemoveCategoryFromShopItems < ActiveRecord::Migration[8.0]
  def change
    remove_column :shop_items, :category, :string
  end
end
