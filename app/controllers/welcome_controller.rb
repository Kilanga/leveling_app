class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!, only: :index
  skip_before_action :ensure_profile_completed, only: :index
  skip_before_action :resolve_due_friend_challenges, only: :index
  skip_before_action :set_unread_notifications_count, only: :index

  STATS_CACHE_TTL = 10.minutes
  TOP_HUNTERS_LIMIT = 5

  def index
    if user_signed_in?
      redirect_to dashboard_path
      return
    end

    landing_stats = cached_landing_stats
    @players_count = landing_stats[:players_count]
    @quests_count = landing_stats[:quests_count]
    @categories_count = landing_stats[:categories_count]
    @completed_quests_total = landing_stats[:completed_quests_total]
    @top_hunters = cached_top_hunters
    @current_season = current_season_readonly

    @invite_ref = params[:ref].to_s.upcase.presence
    @signup_params = {
      ref: @invite_ref,
      utm_source: params[:utm_source].presence || "organic",
      utm_campaign: params[:utm_campaign].presence || "welcome_launch"
    }.compact
  end

  private

  # Stats globales de preuve sociale, mises en cache pour garder la
  # landing rapide (page publique la plus exposée au trafic froid).
  def cached_landing_stats
    Rails.cache.fetch("landing/global_stats", expires_in: STATS_CACHE_TTL) do
      {
        players_count: User.count,
        quests_count: Quest.count,
        categories_count: Category.count,
        completed_quests_total: UserQuest.sum(:completed_count)
      }
    end
  end

  # Meilleurs chasseurs par niveau total, avec leur rang E→S.
  # On sur-échantillonne pour pouvoir écarter les profils incomplets.
  def cached_top_hunters
    Rails.cache.fetch("landing/top_hunters", expires_in: STATS_CACHE_TTL) do
      totals = UserStat.group(:user_id)
                       .order(Arel.sql("SUM(level) DESC"))
                       .limit(TOP_HUNTERS_LIMIT * 2)
                       .sum(:level)
      users = User.where(id: totals.keys).index_by(&:id)

      totals.filter_map do |user_id, total_level|
        user = users[user_id]
        next if user.nil? || user.pseudo.blank?

        { pseudo: user.pseudo, rank: HunterRank.for_level(total_level) }
      end.first(TOP_HUNTERS_LIMIT)
    end
  end

  # Lecture seule : on n'écrit jamais en base depuis la landing publique.
  def current_season_readonly
    return nil unless SeasonManager.ready?

    Season.covering(Time.zone.today).first
  end
end
