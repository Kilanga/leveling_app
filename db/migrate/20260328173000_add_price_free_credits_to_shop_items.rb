class AddPriceFreeCreditsToShopItems < ActiveRecord::Migration[8.1]
  def change
    add_column :shop_items, :price_free_credits, :integer
  end
end
