class LeaderboardController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:category_id].present? && !params[:category_id].empty?
      @players = User.joins(:user_stats)
                     .where(user_stats: { category_id: params[:category_id] })
                     .group("users.id")
                     .select("users.*, MAX(user_stats.total_xp) AS total_xp_sum")
                     .order("total_xp_sum DESC")
    else
      @players = User.joins(:user_stats)
                     .group("users.id")
                     .select("users.*, COALESCE(SUM(user_stats.total_xp), 0) as total_xp_sum")
                     .order("total_xp_sum DESC")
    end

    friend_ids = current_user.friendships.where(status: "accepted").pluck(:friend_id) +
                 Friendship.where(friend: current_user, status: "accepted").pluck(:user_id)

    if friend_ids.any?
      @most_completed_quests = UserQuest.joins(:quest, :user)
                                        .where(user_id: friend_ids)
                                        .select("user_id, quest_id, COUNT(*) AS completed_count")
                                        .group("user_id, quest_id")
                                        .order(Arel.sql("COUNT(*) DESC"))
                                        .limit(5)
                                        .includes(:user, :quest)

      @recent_quests = UserQuest.includes(:user, :quest)
                                .where(user_id: friend_ids)
                                .order(updated_at: :desc)
                                .limit(5)
    else
      @most_completed_quests = []
      @recent_quests = []
    end
  end

  def show
    @player = User.find(params[:id])

    # Top 3 catégories du joueur
    @top_categories = @player.user_stats.includes(:category).order(total_xp: :desc).limit(3)

    # Quêtes les plus complétées par ce joueur
    @most_completed_quests = @player.user_quests.joins(:quest)
                      .select("user_quests.quest_id, COUNT(*) AS completed_count")
                      .group("user_quests.quest_id")
                      .order("completed_count DESC")
                      .limit(5)
                      .includes(:quest)

    # Ses dernières quêtes
    @recent_quests = @player.user_quests.includes(:quest).order(updated_at: :desc).limit(5)
  end
end
