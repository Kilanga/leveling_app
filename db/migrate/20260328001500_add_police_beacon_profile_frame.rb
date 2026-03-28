class AddPoliceBeaconProfileFrame < ActiveRecord::Migration[8.1]
  def up
    ShopItem.find_or_create_by!(name: "Cadre Gyrophare Police", item_type: "profile_frame") do |item|
      item.description = "Cadre tactique rouge/bleu avec flash alterne type gyrophare."
      item.rarity = "epic"
      item.price_coins = 650
      item.price_euros = nil
    end
  end

  def down
    ShopItem.where(name: "Cadre Gyrophare Police", item_type: "profile_frame").delete_all
  end
end
