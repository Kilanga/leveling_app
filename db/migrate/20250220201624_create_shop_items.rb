class CreateShopItems < ActiveRecord::Migration[8.0]
  def change
    create_table :shop_items do |t|
      t.string :name
      t.text :description
      t.string :category
      t.string :rarity
      t.integer :price_coins
      t.integer :price_euros
      t.string :image_url

      t.timestamps
    end
  end
end
