class LeaderboardController < ApplicationController
  before_action :authenticate_user!

  def index
    WeeklyLeague.ensure_user_league_slot!(current_user)
    WeeklyLeague.settle_leagues_if_needed!

    league_users_scope = User.all
    league_users_scope = league_users_scope.where(league_tier: current_user[:league_tier].to_i.nonzero? || 1) if User.column_names.include?("league_tier")
    league_users_scope = league_users_scope.where(league_room: current_user[:league_room].to_i.nonzero? || 1) if User.column_names.include?("league_room")

    full_standings = WeeklyLeague.standings(league_users_scope.to_a)
    @league_standings = full_standings
    @my_league_entry = full_standings.find { |entry| entry[:user].id == current_user.id }
    @current_league_name = current_user.league_tier_name
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
