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
    @coins_prices = COIN_PACKS.map { |label, config| { label: label, amount: config[:amount], coins: config[:coins] } }
    @boosts = BOOST_PACKS.map { |label, config| { label: label, amount: config[:amount], duration: config[:duration] } }

    @shop_items = ShopItem.where.not(item_type: "currency")
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

    if Purchase.exists?(transaction_id: checkout_session.id)
      return redirect_to root_path, notice: "Achat deja confirme !"
    end

    email_summary = nil
    email_amount_eur = nil

    if (shop_item_id = session.delete(:shop_item_id)).present?
      item = ShopItem.find(shop_item_id)
      current_user.user_items.find_or_create_by!(shop_item: item)
      email_summary = "#{item.name} (#{item.item_type})"
      email_amount_eur = item.price_euros
    elsif (pending_purchase = session.delete(:pending_purchase)).present?
      apply_pending_purchase!(pending_purchase)
      email_summary = pending_purchase_summary(pending_purchase)
      email_amount_eur = checkout_session.amount_total.to_i / 100.0
    end

    Purchase.create!(
      user: current_user,
      amount: [checkout_session.amount_total.to_i / 100, 1].max,
      item_type: "checkout",
      status: "completed",
      transaction_id: checkout_session.id
    )

    send_purchase_confirmation_email(summary: email_summary, amount_eur: email_amount_eur)

    redirect_to root_path, notice: "Achat réussi !"
  end

  def cancel
    redirect_to new_purchase_path, alert: "Paiement annulé."
  end

  private

  def handle_shop_item_purchase
    item = ShopItem.find(params[:shop_item_id])

    if item.price_coins.present? && current_user.coins >= item.price_coins
      current_user.decrement!(:coins, item.price_coins)
      current_user.user_items.find_or_create_by!(shop_item: item)
      redirect_to new_purchase_path, notice: "Objet acheté avec succès !"
    elsif item.price_euros.present?
      session[:shop_item_id] = item.id
      redirect_to create_checkout_session(
        item.name,
        item.price_euros,
        {
          kind: "shop_item",
          user_id: current_user.id,
          shop_item_id: item.id
        }
      ), allow_other_host: true
    else
      redirect_to new_purchase_path, alert: "Achat impossible."
    end
  end

  def handle_pack_purchase
    item_type = params[:item_type].to_s
    amount = params[:amount].to_i

    if (coin_pack = COIN_PACKS[item_type]) && coin_pack[:amount] == amount
      session[:pending_purchase] = { "kind" => "coins", "coins" => coin_pack[:coins] }
      redirect_to create_checkout_session(
        item_type,
        amount,
        {
          kind: "coins",
          user_id: current_user.id,
          coins: coin_pack[:coins]
        }
      ), allow_other_host: true
    elsif (boost_pack = BOOST_PACKS[item_type]) && boost_pack[:amount] == amount
      session[:pending_purchase] = { "kind" => "boost", "duration_seconds" => boost_pack[:duration].to_i }
      redirect_to create_checkout_session(
        item_type,
        amount,
        {
          kind: "boost",
          user_id: current_user.id,
          duration_seconds: boost_pack[:duration].to_i
        }
      ), allow_other_host: true
    else
      redirect_to new_purchase_path, alert: "Pack invalide."
    end
  end

  def apply_pending_purchase!(pending_purchase)
    case pending_purchase["kind"]
    when "coins"
      current_user.increment!(:coins, pending_purchase["coins"].to_i)
    when "boost"
      duration = pending_purchase["duration_seconds"].to_i.seconds
      base_time = [current_user.boost_expires_at, Time.current].compact.max
      current_user.update!(boost_expires_at: base_time + duration)
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

  def pending_purchase_summary(pending_purchase)
    case pending_purchase["kind"]
    when "coins"
      "Pack coins: +#{pending_purchase["coins"].to_i}"
    when "boost"
      duration_days = (pending_purchase["duration_seconds"].to_i / 1.day).to_i
      "Boost XP x2 (#{duration_days} jour#{duration_days > 1 ? 's' : ''})"
    else
      "Achat boutique"
    end
  end

  def send_purchase_confirmation_email(summary:, amount_eur:)
    return if summary.blank?

    UserMailer.purchase_confirmation(
      user: current_user,
      summary: summary,
      amount_eur: amount_eur
    ).deliver_later
  rescue StandardError => e
    Rails.logger.warn("Purchase confirmation email failed: #{e.class} #{e.message}")
  end
end
