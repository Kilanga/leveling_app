# Offres du jour : 3 objets de boutique en promotion, rotation quotidienne
# déterministe (seed = date), remise appliquée côté serveur.
class DailyShopDeals
  DEALS_COUNT = 3
  DISCOUNT_RATE = 0.25
  ELIGIBLE_TYPES = %w[profile_frame xp_theme profile_card cosmetic title].freeze

  class << self
    def today(date: Date.current)
      items = ShopItem.where.not(price_coins: nil)
                      .where(item_type: ELIGIBLE_TYPES)
                      .order(:id).to_a
      return [] if items.empty?

      rng = Random.new(date.strftime("%Y%m%d").to_i)
      items.sample([ DEALS_COUNT, items.size ].min, random: rng).map do |item|
        { item: item, original_price: item.price_coins, deal_price: deal_price(item) }
      end
    end

    # Prix effectif d'un objet (remisé s'il fait partie des offres du jour).
    def price_for(item, date: Date.current)
      deal = today(date: date).find { |d| d[:item].id == item.id }
      deal ? deal[:deal_price] : item.price_coins
    end

    def deal_price(item)
      (item.price_coins * (1 - DISCOUNT_RATE)).ceil
    end
  end
end
