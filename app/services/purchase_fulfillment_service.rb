class PurchaseFulfillmentService
  class << self
    def process_checkout_session(checkout_session)
      transaction_id = checkout_session.id
      return if Purchase.exists?(transaction_id: transaction_id)

      user = User.find_by(id: checkout_session.metadata["user_id"])
      return if user.nil?

      case checkout_session.metadata["kind"]
      when "shop_item"
        process_shop_item!(user, checkout_session, transaction_id)
      when "coins"
        process_coins!(user, checkout_session, transaction_id)
      when "boost"
        process_boost!(user, checkout_session, transaction_id)
      else
        process_generic!(user, checkout_session, transaction_id)
      end
    end

    private

    def process_shop_item!(user, checkout_session, transaction_id)
      item = ShopItem.find_by(id: checkout_session.metadata["shop_item_id"])
      return if item.nil?

      user.user_items.find_or_create_by!(shop_item: item)
      create_purchase_record!(user, transaction_id, checkout_session, item_type: "shop_item")
      ProductAnalytics.track(user: user, event_name: "purchase_completed", metadata: { kind: "shop_item", shop_item_id: item.id, transaction_id: transaction_id })
      send_purchase_email!(user, "#{item.name} (#{item.item_type})", checkout_session)
    end

    def process_coins!(user, checkout_session, transaction_id)
      coins = checkout_session.metadata["coins"].to_i
      return if coins <= 0

      user.increment!(:coins, coins)
      create_purchase_record!(user, transaction_id, checkout_session, item_type: "coins")
      ProductAnalytics.track(user: user, event_name: "purchase_completed", metadata: { kind: "coins", coins: coins, transaction_id: transaction_id })

      send_purchase_email!(user, "Pack coins: +#{coins}", checkout_session)
    end

    def process_boost!(user, checkout_session, transaction_id)
      duration_seconds = checkout_session.metadata["duration_seconds"].to_i
      return if duration_seconds <= 0

      duration = duration_seconds.seconds
      base_time = [user.boost_expires_at, Time.current].compact.max
      user.update!(boost_expires_at: base_time + duration)

      create_purchase_record!(user, transaction_id, checkout_session, item_type: "boost")
      ProductAnalytics.track(user: user, event_name: "purchase_completed", metadata: { kind: "boost", duration_seconds: duration_seconds, transaction_id: transaction_id })
      duration_days = (duration_seconds / 1.day).to_i
      send_purchase_email!(user, "Boost XP x2 (#{duration_days} jour#{duration_days > 1 ? 's' : ''})", checkout_session)
    end

    def process_generic!(user, checkout_session, transaction_id)
      create_purchase_record!(user, transaction_id, checkout_session, item_type: "checkout")
      send_purchase_email!(user, "Achat boutique", checkout_session)
    end

    def create_purchase_record!(user, transaction_id, checkout_session, item_type:)
      Purchase.create!(
        user: user,
        amount: [checkout_session.amount_total.to_i / 100, 1].max,
        item_type: item_type,
        status: "completed",
        transaction_id: transaction_id
      )
    end

    def send_purchase_email!(user, summary, checkout_session)
      UserMailer.purchase_confirmation(
        user: user,
        summary: summary,
        amount_eur: checkout_session.amount_total.to_i / 100.0
      ).deliver_later
    rescue StandardError => e
      Rails.logger.warn("Purchase confirmation email failed: #{e.class} #{e.message}")
    end
  end
end
