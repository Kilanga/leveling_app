require "test_helper"

class DailyShopDealsTest < ActiveSupport::TestCase
  setup do
    5.times do |i|
      ShopItem.find_or_create_by!(name: "Deal Item #{i}", item_type: "profile_frame") do |item|
        item.rarity = "rare"
        item.description = "Objet de test #{i}"
        item.price_coins = 100 + i * 100
      end
    end
  end

  test "sélection déterministe pour une même date" do
    date = Date.new(2026, 7, 5)
    first = DailyShopDeals.today(date: date).map { |d| d[:item].id }
    second = DailyShopDeals.today(date: date).map { |d| d[:item].id }
    assert_equal first, second
    assert_equal 3, first.size
  end

  test "la rotation change selon la date" do
    ids_by_date = (0..6).map { |i| DailyShopDeals.today(date: Date.new(2026, 7, 1) + i).map { |d| d[:item].id } }
    assert ids_by_date.uniq.size > 1, "les offres doivent varier au fil des jours"
  end

  test "price_for applique la remise aux offres du jour uniquement" do
    date = Date.current
    deal = DailyShopDeals.today(date: date).first
    expected = (deal[:item].price_coins * 0.75).ceil
    assert_equal expected, DailyShopDeals.price_for(deal[:item], date: date)

    non_deal = ShopItem.where.not(id: DailyShopDeals.today(date: date).map { |d| d[:item].id })
                       .where.not(price_coins: nil).first
    assert_equal non_deal.price_coins, DailyShopDeals.price_for(non_deal, date: date) if non_deal
  end
end
