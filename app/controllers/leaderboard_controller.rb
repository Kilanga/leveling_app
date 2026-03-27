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

    @player_stats = @player.user_stats.includes(:category).order(total_xp: :desc)
    @top_categories = @player_stats.limit(3)
    @player_total_level = @player_stats.sum(&:level)
    @player_completed_quests_total = @player.user_quests.sum(:completed_count)
    @player_xp_this_week = @player.user_quests.where(completed: true, updated_at: Time.current.all_week).joins(:quest).sum("quests.xp")
    @player_weekly_quests = @player.user_weekly_quests.joins(:weekly_quest)
                                 .where("weekly_quests.valid_until >= ?", Time.current)
                                 .includes(:weekly_quest)
                                 .order("weekly_quests.valid_until ASC")
    @player_active_quests = @player.user_quests
                   .where(completed: false, active: true)
                   .includes(:quest)
                   .order(updated_at: :desc)

    @most_completed_quests = @player.user_quests
              .select("user_quests.quest_id, COUNT(*) AS completed_count, MAX(user_quests.updated_at) AS last_completed_at")
                      .group("user_quests.quest_id")
              .order(Arel.sql("COUNT(*) DESC"))
              .limit(3)
              .preload(:quest)

    @recent_quests = @player.user_quests.where(completed: true).includes(:quest).order(updated_at: :desc).limit(8)
  end
end
