class LeaderboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @players = User.order(xp: :desc).limit(10)

    friend_ids = current_user.friendships.where(status: "accepted").pluck(:friend_id) +
                 Friendship.where(friend: current_user, status: "accepted").pluck(:user_id)

    if friend_ids.any?
      @most_completed_quests = UserQuest.joins(:quest, :user)
                                        .where(user_id: friend_ids)
                                        .select("user_quests.*, COUNT(user_quests.id) AS completed_count")
                                        .group("user_quests.id, quests.id, users.id")
                                        .order(Arel.sql("COUNT(user_quests.id) DESC")) # ✅ Correction ici
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
    @top_categories = @player.user_stats.order(xp: :desc).limit(3)


    # Quêtes les plus complétées par ce joueur
    @most_completed_quests = @player.user_quests.joins(:quest)
                                      .select("quests.*, COUNT(user_quests.id) AS completed_count")
                                      .group("quests.id")
                                      .order("completed_count DESC")
                                      .limit(5)

    # Ses dernières quêtes
    @recent_quests = @player.user_quests.includes(:quest).order(updated_at: :desc).limit(5)
  end
end
