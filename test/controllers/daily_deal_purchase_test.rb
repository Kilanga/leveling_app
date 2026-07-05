class DailyDealPurchaseTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    5.times do |i|
      ShopItem.find_or_create_by!(name: "Deal Item #{i}", item_type: "profile_frame") do |item|
        item.rarity = "rare"
        item.description = "Objet de test #{i}"
        item.price_coins = 100 + i * 100
      end
    end
    @user = create(:user, confirmed_at: Time.current)
    @user.update_column(:coins, 10_000)
    sign_in @user
  end

  test "l'achat d'une offre du jour débite le prix remisé" do
    deal = DailyShopDeals.today.first
    post purchases_path, params: { shop_item_id: deal[:item].id }

    assert @user.user_items.exists?(shop_item: deal[:item]), "l'objet doit être attribué"
    assert_equal 10_000 - deal[:deal_price], @user.reload.coins, "le prix remisé doit être débité"
  end
end
