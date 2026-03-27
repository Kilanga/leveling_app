class LeaderboardController < ApplicationController
  before_action :authenticate_user!

  TOP_PLAYERS_LIMIT = 10

  def index
    if params[:category_id].present? && !params[:category_id].empty?
      @players = User.joins(:user_stats)
                     .where(user_stats: { category_id: params[:category_id] })
                     .group("users.id")
                     .select("users.*, MAX(user_stats.total_xp) AS total_xp_sum")
                     .order("total_xp_sum DESC")
                     .limit(TOP_PLAYERS_LIMIT)
    else
      @players = User.joins(:user_stats)
                     .group("users.id")
                     .select("users.*, COALESCE(SUM(user_stats.total_xp), 0) as total_xp_sum")
                     .order("total_xp_sum DESC")
                     .limit(TOP_PLAYERS_LIMIT)
    end

    @league_standings = WeeklyLeague.standings(@players.to_a).first(TOP_PLAYERS_LIMIT)
    @league_by_user_id = @league_standings.index_by { |entry| entry[:user].id }
  end

  def show
    @player = User.find(params[:id])
    @friendship_with_current = Friendship.where(user: current_user, friend: @player)
                                       .or(Friendship.where(user: @player, friend: current_user))
                                       .first
    @player_pending_limit_reached = Friendship.pending.where(friend: @player).count >= Friendship::MAX_PENDING_RECEIVED

    # Top 3 catégories du joueur
    @top_categories = @player.user_stats.includes(:category).order(total_xp: :desc).limit(3)

    # Quêtes les plus complétées par ce joueur
    @most_completed_quests = @player.user_quests
                      .select("user_quests.quest_id, COUNT(*) AS completed_count")
                      .group("user_quests.quest_id")
              .order(Arel.sql("COUNT(*) DESC"))
                      .limit(5)
              .preload(:quest)

    # Ses dernières quêtes
    @recent_quests = @player.user_quests.includes(:quest).order(updated_at: :desc).limit(5)
  end
end
