class PurchasesController < ApplicationController
  before_action :authenticate_user!
  SHOP_CHALLENGE_REWARD_FREE_CREDITS = 200
  WELCOME_BONUS_BY_VARIANT = {
    "control" => 0.10,
    "treatment" => 0.20
  }.freeze

  COIN_PACKS = {
    "100 pièces" => { amount: 5, coins: 100 },
    "500 pièces" => { amount: 20, coins: 500 },
    "1000 pièces" => { amount: 35, coins: 1000 }
  }.freeze

  BOOST_PACKS = {
    "Boost XP x2 (1 jour)" => { amount: 10, duration: 1.day },
    "Boost XP x2 (1 semaine)" => { amount: 50, duration: 7.days }
  }.freeze

  DEFAULT_COSMETIC_ITEMS = [
    {
      name: "Cadre Standard",
      item_type: "profile_frame",
      description: "Bordure bleu luminescent autour de ton pseudo au classement.",
      rarity: "common",
      price_coins: nil,
      price_euros: nil
    },
    {
      name: "Cadre Electrique",
      item_type: "profile_frame",
      description: "Bordure violette scintillante avec effet de foudre.",
      rarity: "rare",
      price_coins: 300,
      price_euros: nil
    },
    {
      name: "Cadre Legendaire",
      item_type: "profile_frame",
      description: "Bordure doree imposante avec particules de feu.",
      rarity: "epic",
      price_coins: 600,
      price_euros: nil
    },
    {
      name: "Cadre Gyrophare Police",
      item_type: "profile_frame",
      description: "Cadre tactique rouge/bleu avec flash alterne type gyrophare.",
      rarity: "epic",
      price_coins: 650,
      price_euros: nil
    },
    {
      name: "Theme XP Standard",
      item_type: "xp_theme",
      description: "Barre XP bleu classique avec progression lineaire.",
      rarity: "common",
      price_coins: nil,
      price_euros: nil
    },
    {
      name: "Theme XP Samourai",
      item_type: "xp_theme",
      description: "Barre rouge sang avec degrade orange pour une vibe guerriere.",
      rarity: "rare",
      price_coins: 200,
      price_euros: nil
    },
    {
      name: "Theme XP Neon",
      item_type: "xp_theme",
      description: "Barre vert luminescent cyberpunk avec glow intense.",
      rarity: "rare",
      price_coins: 200,
      price_euros: nil
    },
    {
      name: "Theme XP Legendaire",
      item_type: "xp_theme",
      description: "Barre degradee or-violet avec particules de magie.",
      rarity: "epic",
      price_coins: 400,
      price_euros: nil
    },
    {
      name: "Carte de Visite Standard",
      item_type: "profile_card",
      description: "Carte simple noire avec bordure grise.",
      rarity: "common",
      price_coins: nil,
      price_euros: nil
    },
    {
      name: "Carte de Visite Bleu Nuit",
      item_type: "profile_card",
      description: "Carte elegante bleu marine avec accent or.",
      rarity: "rare",
      price_coins: 250,
      price_euros: nil
    },
    {
      name: "Carte de Visite Incendie",
      item_type: "profile_card",
      description: "Carte avec gradient rouge-orange, texture de feu.",
      rarity: "rare",
      price_coins: 250,
      price_euros: nil
    },
    {
      name: "Carte de Visite Royale",
      item_type: "profile_card",
      description: "Carte luxe violet-or avec couronne animee.",
      rarity: "epic",
      price_coins: 500,
      price_euros: nil
    }
  ].freeze

  def new
    ensure_default_cosmetic_items!

    @entry_offer_variant = Experimentation.variant_for(user: current_user, experiment_key: "entry_offer_copy")
    @entry_offer_enabled = entry_offer_eligible?
    @entry_offer_bonus_rate = entry_offer_bonus_rate

    @active_shop_tab = params[:tab].presence_in(%w[boosts titles cosmetics rewards]) || "cosmetics"
    @focus_category_name = current_user.user_stats.includes(:category).order(total_xp: :desc).first&.category&.name || "tes objectifs"

    @coins_prices = COIN_PACKS.map do |label, config|
      bonus_coins = welcome_bonus_coins_for(config[:coins])
      total_coins = config[:coins] + bonus_coins
      {
        label: label,
        amount: config[:amount],
        coins: config[:coins],
        bonus_coins: bonus_coins,
        total_coins: total_coins,
        description: coin_pack_description(total_coins)
      }
    end

    @boosts = BOOST_PACKS.map do |label, config|
      {
        label: label,
        amount: config[:amount],
        duration: config[:duration],
        description: boost_description(config[:duration])
      }
    end
    @best_value_pack_label = @coins_prices.max_by { |option| option[:total_coins].to_f / [option[:amount], 1].max }[:label]

    @title_items = ShopItem.where(item_type: "title")
                 .where("price_coins IS NOT NULL OR price_euros IS NOT NULL")
                 .where.not(rarity: "common")
                 .order(rarity: :asc, name: :asc)
    @cosmetic_items = ShopItem.where(item_type: "cosmetic").order(rarity: :asc, name: :asc)
    @frame_items = ShopItem.where(item_type: "profile_frame")
                 .where("price_coins IS NOT NULL OR price_euros IS NOT NULL")
                 .order(rarity: :asc, name: :asc)
    @theme_items = ShopItem.where(item_type: "xp_theme")
                 .where("price_coins IS NOT NULL OR price_euros IS NOT NULL")
                 .order(rarity: :asc, name: :asc)
    @card_items = ShopItem.where(item_type: "profile_card")
                 .where("price_coins IS NOT NULL OR price_euros IS NOT NULL")
                 .order(rarity: :asc, name: :asc)
    @owned_item_ids = current_user.user_items.pluck(:shop_item_id)
    @total_level = current_user.user_stats.sum(:level)
    @recommended_shop_items = recommended_shop_items
    @item_personalized_descriptions = personalized_descriptions_by_item_id(@title_items + @cosmetic_items + @frame_items + @theme_items + @card_items + @recommended_shop_items)

    @shop_challenge = build_shop_challenge
    @shop_challenge_claimed = shop_challenge_claimed?
  end

  def claim_weekly_challenge
    challenge = build_shop_challenge

    unless challenge[:completed_all]
      return redirect_to new_purchase_path(tab: "cosmetics"), alert: "Defi hebdo incomplet pour le moment."
    end

    if shop_challenge_claimed?
      return redirect_to new_purchase_path(tab: "cosmetics"), alert: "Recompense hebdo deja recuperee."
    end

    ActiveRecord::Base.transaction do
      current_user.add_free_credits!(SHOP_CHALLENGE_REWARD_FREE_CREDITS)
      Purchase.create!(
        user: current_user,
        amount: SHOP_CHALLENGE_REWARD_FREE_CREDITS,
        item_type: "shop_challenge_reward",
        status: "completed",
        transaction_id: weekly_shop_challenge_token
      )
    end

    ProductAnalytics.track(user: current_user, event_name: "shop_challenge_claimed", metadata: { reward_free_credits: SHOP_CHALLENGE_REWARD_FREE_CREDITS })

    redirect_to new_purchase_path(tab: "cosmetics"), notice: "+#{SHOP_CHALLENGE_REWARD_FREE_CREDITS} credits gratuits recuperes via le defi boutique !"
  rescue ActiveRecord::RecordNotUnique
    redirect_to new_purchase_path(tab: "cosmetics"), alert: "Recompense hebdo deja recuperee."
  end

  def create
    ProductAnalytics.track(user: current_user, event_name: "purchase_started", metadata: { shop_item_id: params[:shop_item_id], item_type: params[:item_type], amount: params[:amount] })

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

  if item.item_type == "title" && (item.rarity == "common" || (item.price_coins.blank? && item.price_euros.blank? && item.price_free_credits.blank?))
    return redirect_to new_purchase_path, alert: "Ce titre se débloque via des objectifs, pas en boutique."
  end

  if current_user.user_items.exists?(shop_item: item)
    return redirect_to new_purchase_path, alert: "Vous possedez deja cet objet."
  end

  if item.price_coins.present?
    return purchase_with_orbes!(item, item.price_coins, new_purchase_path)
  end

  if item.price_free_credits.present?
    return purchase_free_reward_with_explicit_currency!(item)
  end

  if item.price_euros.present?
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
    return safe_redirect_to_checkout(checkout_url)
  end

  redirect_to new_purchase_path, alert: "Achat impossible."
end

def purchase_free_reward_with_explicit_currency!(item)
  selected_currency = params[:currency].to_s
  fallback_orbes_price = (item.price_free_credits / 2.0).ceil

  if selected_currency == "fragments"
    if current_user.free_credits_balance >= item.price_free_credits
      current_user.update!(free_credits: current_user.free_credits_balance - item.price_free_credits)
      current_user.user_items.find_or_create_by!(shop_item: item)
      return redirect_to new_purchase_path(tab: "rewards"), notice: "Objet debloque avec tes Fragments !"
    end

    return redirect_to new_purchase_path(tab: "rewards"), alert: "Tu n'as pas assez de Fragments pour cet achat."
  end

  if selected_currency == "orbes"
    return purchase_with_orbes!(item, fallback_orbes_price, new_purchase_path(tab: "rewards"), "Objet debloque avec tes Orbes (tarif de secours) !")
  end

  redirect_to new_purchase_path(tab: "rewards"), alert: "Choisis une monnaie valide pour cet achat (Fragments ou Orbes)."
end

def purchase_with_orbes!(item, orbes_price, redirect_path, success_notice = "Objet acheté avec succès!")
  if current_user.coins >= orbes_price
    current_user.decrement!(:coins, orbes_price)
    current_user.user_items.find_or_create_by!(shop_item: item)
    return redirect_to redirect_path, notice: success_notice
  end

  redirect_to redirect_path, alert: "Tu n'as pas assez d'Orbes pour acheter cet objet."
end

def handle_pack_purchase

    item_type = params[:item_type].to_s
    amount = params[:amount].to_i

    if (coin_pack = COIN_PACKS[item_type]) && coin_pack[:amount] == amount
      bonus_coins = welcome_bonus_coins_for(coin_pack[:coins])
      total_coins = coin_pack[:coins] + bonus_coins
      session[:pending_purchase] = { "kind" => "coins", "coins" => total_coins }
      checkout_url = create_checkout_session(
        item_type,
        amount,
        {
          kind: "coins",
          user_id: current_user.id,
          coins: total_coins,
          base_coins: coin_pack[:coins],
          bonus_coins: bonus_coins,
          entry_offer_applied: (bonus_coins > 0)
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
    candidates = ShopItem.where(item_type: %w[title cosmetic])
                         .where("price_coins IS NOT NULL OR price_euros IS NOT NULL")
                         .where.not(id: @owned_item_ids)
                         .where.not(rarity: "common")
                         .to_a

    candidates
      .sort_by do |item|
        affordable_rank = item.price_coins.present? && item.price_coins <= current_user.coins ? 0 : 1
        rarity_rank = rarity_order.fetch(item.rarity, 9)
        price_rank = item.price_coins || (item.price_euros.to_i * 100)
        [affordable_rank, rarity_rank, price_rank, item.name.to_s]
      end
      .first(4)
  end

  def personalized_descriptions_by_item_id(items)
    items.uniq.each_with_object({}) do |item, result|
      result[item.id] = personalized_item_description(item)
    end
  end

  def personalized_item_description(item)
    base = item.description.to_s.strip
    base = "Objet cosmétique exclusif pour renforcer ton identité en jeu." if base.blank?
    base
  end

  def coin_pack_description(coins)
    if coins >= 1000
      "Gros refill pour enchainer les achats premium lies a #{@focus_category_name.downcase}."
    elsif coins >= 500
      "Pack equilibre pour maintenir ton rythme sur #{@focus_category_name.downcase}."
    else
      "Top-up rapide pour debloquer un premier item utile."
    end
  end

  def boost_description(duration)
    if duration >= 7.days
      "Boost longue duree pour grinder toute la semaine."
    else
      "Coup d'accelerateur parfait pour une session intense."
    end
  end

  def build_shop_challenge
    equipped_cosmetic = current_user.active_title_id.present? || current_user.active_avatar_item_id.present?
    owns_epic_or_legendary = current_user.user_items.joins(:shop_item).where(shop_items: { rarity: %w[epic legendary] }).exists?
    collection_size = current_user.user_items.joins(:shop_item).where(shop_items: { item_type: %w[title cosmetic] }).distinct.count("shop_items.id")
    owns_three_cosmetics = collection_size >= 3

    steps = [
      { label: "Equiper un cosmétique", completed: equipped_cosmetic },
      { label: "Posseder un item Epic ou Legendary", completed: owns_epic_or_legendary },
      { label: "Construire une collection de 3 cosmetiques", completed: owns_three_cosmetics }
    ]

    completed_count = steps.count { |step| step[:completed] }
    {
      steps: steps,
      completed_count: completed_count,
      total_count: steps.size,
      completed_all: completed_count == steps.size
    }
  rescue StandardError => e
    Rails.logger.error("Shop challenge build failed: #{e.class} #{e.message}")
    {
      steps: [],
      completed_count: 0,
      total_count: 0,
      completed_all: false
    }
  end

  def weekly_shop_challenge_token
    now = Time.zone.now.to_date
    "shop_weekly_challenge:#{current_user.id}:#{now.cwyear}-#{now.cweek}"
  end

  def shop_challenge_claimed?
    Purchase.exists?(transaction_id: weekly_shop_challenge_token)
  end

  def ensure_default_cosmetic_items!
    return if ShopItem.where(item_type: %w[profile_frame xp_theme profile_card]).exists?

    DEFAULT_COSMETIC_ITEMS.each do |attributes|
      item = ShopItem.find_or_initialize_by(name: attributes[:name], item_type: attributes[:item_type])
      item.assign_attributes(attributes)
      item.save!
    end
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

  def entry_offer_eligible?
    current_user.purchases.where(item_type: "coins").none?
  end

  def entry_offer_bonus_rate
    return 0.0 unless entry_offer_eligible?

    variant = Experimentation.variant_for(user: current_user, experiment_key: "entry_offer_copy")
    WELCOME_BONUS_BY_VARIANT.fetch(variant, 0.0)
  rescue StandardError
    0.0
  end

  def welcome_bonus_coins_for(base_coins)
    return 0 unless base_coins.to_i.positive?

    (base_coins.to_i * entry_offer_bonus_rate).round
  end
end
