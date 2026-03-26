class PurchasesController < ApplicationController
  before_action :authenticate_user!

  COIN_PACKS = {
    "100 pièces" => { amount: 5, coins: 100 },
    "500 pièces" => { amount: 20, coins: 500 },
    "1000 pièces" => { amount: 35, coins: 1000 }
  }.freeze

  BOOST_PACKS = {
    "Boost XP x2 (1 jour)" => { amount: 10, duration: 1.day },
    "Boost XP x2 (1 semaine)" => { amount: 50, duration: 7.days }
  }.freeze

  def new
    @active_shop_tab = params[:tab].presence_in(%w[packs boosts cosmetics]) || "packs"
    @coins_prices = COIN_PACKS.map { |label, config| { label: label, amount: config[:amount], coins: config[:coins] } }
    @boosts = BOOST_PACKS.map { |label, config| { label: label, amount: config[:amount], duration: config[:duration] } }
    @best_value_pack_label = @coins_prices.max_by { |option| option[:coins].to_f / [option[:amount], 1].max }[:label]

    @title_items = ShopItem.where(item_type: "title").order(rarity: :asc, name: :asc)
    @cosmetic_items = ShopItem.where(item_type: "cosmetic").order(rarity: :asc, name: :asc)
    @owned_item_ids = current_user.user_items.pluck(:shop_item_id)
    @total_level = current_user.user_stats.sum(:level)
    @recommended_shop_items = recommended_shop_items
  end

  def create
    return handle_shop_item_purchase if params[:shop_item_id].present?
    return handle_pack_purchase if params[:item_type].present? && params[:amount].present?

    redirect_to new_purchase_path, alert: "Achat impossible."
  end

  def success
    checkout_session_id = params[:session_id]
    return redirect_to new_purchase_path, alert: "Session Stripe invalide." if checkout_session_id.blank?

    checkout_session = Stripe::Checkout::Session.retrieve(checkout_session_id)
    unless checkout_session.payment_status == "paid"
      return redirect_to new_purchase_path, alert: "Paiement non validé."
    end

    metadata_user_id = checkout_session.metadata["user_id"].to_i
    if metadata_user_id.positive? && metadata_user_id != current_user.id
      return redirect_to new_purchase_path, alert: "Session de paiement invalide pour cet utilisateur."
    end

    PurchaseFulfillmentService.process_checkout_session(checkout_session)

    # Keep these keys short-lived and best-effort cleaned after checkout return.
    session.delete(:shop_item_id)
    session.delete(:pending_purchase)

    redirect_to root_path, notice: "Achat confirme !"
  rescue StandardError => e
    Rails.logger.error("Purchase success flow failed: #{e.class} #{e.message}")
    redirect_to new_purchase_path, alert: "Achat impossible pour le moment."
  end

  def cancel
    redirect_to new_purchase_path, alert: "Paiement annulé."
  end

  private

  def handle_shop_item_purchase
    item = ShopItem.find(params[:shop_item_id])

    if current_user.user_items.exists?(shop_item: item)
      return redirect_to new_purchase_path, alert: "Vous possedez deja cet objet."
    end

    if item.price_coins.present? && current_user.coins >= item.price_coins
      current_user.decrement!(:coins, item.price_coins)
      current_user.user_items.find_or_create_by!(shop_item: item)
      redirect_to new_purchase_path, notice: "Objet acheté avec succès !"
    elsif item.price_euros.present?
      session[:shop_item_id] = item.id
      checkout_url = create_checkout_session(
        item.name,
        item.price_euros,
        {
          kind: "shop_item",
          user_id: current_user.id,
          shop_item_id: item.id
        }
      )
      safe_redirect_to_checkout(checkout_url)
    else
      redirect_to new_purchase_path, alert: "Achat impossible."
    end
  end

  def handle_pack_purchase
    item_type = params[:item_type].to_s
    amount = params[:amount].to_i

    if (coin_pack = COIN_PACKS[item_type]) && coin_pack[:amount] == amount
      session[:pending_purchase] = { "kind" => "coins", "coins" => coin_pack[:coins] }
      checkout_url = create_checkout_session(
        item_type,
        amount,
        {
          kind: "coins",
          user_id: current_user.id,
          coins: coin_pack[:coins]
        }
      )
      safe_redirect_to_checkout(checkout_url)
    elsif (boost_pack = BOOST_PACKS[item_type]) && boost_pack[:amount] == amount
      session[:pending_purchase] = { "kind" => "boost", "duration_seconds" => boost_pack[:duration].to_i }
      checkout_url = create_checkout_session(
        item_type,
        amount,
        {
          kind: "boost",
          user_id: current_user.id,
          duration_seconds: boost_pack[:duration].to_i
        }
      )
      safe_redirect_to_checkout(checkout_url)
    else
      redirect_to new_purchase_path, alert: "Pack invalide."
    end
  end

  def create_checkout_session(product_name, amount_eur, metadata = {})
    Stripe::Checkout::Session.create(
      payment_method_types: ["card"],
      line_items: [{
        price_data: {
          currency: "eur",
          product_data: { name: product_name },
          unit_amount: amount_eur.to_i * 100
        },
        quantity: 1
      }],
      mode: "payment",
      metadata: metadata.transform_values(&:to_s),
      success_url: success_purchases_url(session_id: "{CHECKOUT_SESSION_ID}"),
      cancel_url: cancel_purchases_url
    ).url
  end

  def safe_redirect_to_checkout(checkout_url)
    uri = URI.parse(checkout_url)
    allowed_hosts = [ "checkout.stripe.com", "pay.stripe.com" ]

    unless uri.is_a?(URI::HTTPS) && allowed_hosts.include?(uri.host)
      return redirect_to new_purchase_path, alert: "URL de paiement invalide."
    end

    redirect_to uri.to_s, allow_other_host: true
  rescue URI::InvalidURIError
    redirect_to new_purchase_path, alert: "URL de paiement invalide."
  end

  def recommended_shop_items
    rarity_order = preferred_rarity_order
    candidates = ShopItem.where(item_type: %w[title cosmetic]).where.not(id: @owned_item_ids).to_a

    candidates
      .sort_by do |item|
        affordable_rank = item.price_coins.present? && item.price_coins <= current_user.coins ? 0 : 1
        rarity_rank = rarity_order.fetch(item.rarity, 9)
        price_rank = item.price_coins || (item.price_euros.to_i * 100)
        [affordable_rank, rarity_rank, price_rank, item.name]
      end
      .first(4)
  end

  def preferred_rarity_order
    if @total_level >= 40
      { "legendary" => 0, "epic" => 1, "rare" => 2 }
    elsif @total_level >= 20
      { "epic" => 0, "rare" => 1, "legendary" => 2 }
    else
      { "rare" => 0, "epic" => 1, "legendary" => 2 }
    end
  end
end
