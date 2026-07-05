# Passe de saison : affichage des paliers, réclamation des récompenses,
# achat de la piste premium via Stripe.
class SeasonPassesController < ApplicationController
  include StripeCheckout

  before_action :authenticate_user!
  before_action :ensure_seasons_ready!
  before_action :set_season

  def show
    @state = SeasonPass.state_for(current_user, @season)
    @price_eur = SeasonPass::PRICE_EUR
    @days_remaining = @season.days_remaining
  end

  def claim
    reward = SeasonPass.claim!(
      current_user, @season,
      tier: params[:tier], track: params[:track].to_s
    )

    if reward
      redirect_to season_pass_path, notice: t("flash.season_pass.claimed", reward: reward_sentence(reward))
    else
      redirect_to season_pass_path, alert: t("flash.season_pass.not_claimable")
    end
  end

  def buy
    if SeasonPass.premium?(current_user, @season)
      return redirect_to season_pass_path, alert: t("flash.season_pass.already_premium")
    end

    ProductAnalytics.track(
      user: current_user,
      event_name: "purchase_started",
      metadata: { kind: "season_pass", season_id: @season.id, amount: SeasonPass::PRICE_EUR }
    )

    checkout_url = create_checkout_session(
      t("season_pass.checkout_product_name", name: @season.name),
      SeasonPass::PRICE_EUR,
      { kind: "season_pass", user_id: current_user.id, season_id: @season.id }
    )
    safe_redirect_to_checkout(checkout_url)
  end

  private

  def ensure_seasons_ready!
    redirect_to new_purchase_path, alert: t("flash.season_pass.unavailable") unless SeasonManager.ready?
  end

  def set_season
    @season = SeasonManager.current!
  end

  def reward_sentence(reward)
    parts = []
    parts << t("season_pass.rewards.fragments", count: reward[:fragments]) if reward[:fragments].to_i.positive?
    parts << t("season_pass.rewards.orbs", count: reward[:orbs]) if reward[:orbs].to_i.positive?
    parts << t("season_pass.rewards.boost", count: reward[:boost_days]) if reward[:boost_days].to_i.positive?
    parts << t("season_pass.rewards.title") if reward[:title]
    parts.join(" + ")
  end
end
