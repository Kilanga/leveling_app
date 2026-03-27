class FriendsController < ApplicationController
  before_action :authenticate_user!

  def index
    sent_friend_ids = current_user.friendships.accepted.pluck(:friend_id)
    received_friend_ids = Friendship.accepted.where(friend_id: current_user.id).pluck(:user_id)
    friend_ids = (sent_friend_ids + received_friend_ids).uniq
    @friends = User.where(id: friend_ids).distinct

    pending_sent_ids = current_user.friendships.pending.pluck(:friend_id)
    pending_received_ids = Friendship.pending.where(friend_id: current_user.id).pluck(:user_id)
    @pending_sent_requests = User.where(id: pending_sent_ids)
    @pending_received_requests = User.where(id: pending_received_ids)
    @active_friend_challenges = FriendChallenge.active
                                             .where("challenger_id = :id OR challenged_id = :id", id: current_user.id)
                                             .includes(:challenger, :challenged)
                                             .order(ends_at: :asc)
    @invite_url = welcome_url(
      ref: current_user.referral_code,
      utm_source: "invite",
      utm_campaign: "player_referral"
    )

    if friend_ids.any?
      @most_completed_quests = UserQuest.joins(:quest, :user)
                                        .where(user_id: friend_ids)
                                        .select("user_id, quest_id, COUNT(*) AS completed_count")
                                        .group("user_id, quest_id")
                                        .order(Arel.sql("COUNT(*) DESC"))
                                        .limit(5)
                                        .preload(:user, :quest)

      @recent_quests = UserQuest.includes(:user, :quest)
                                .where(user_id: friend_ids)
                                .order(updated_at: :desc)
                                .limit(5)
    else
      @most_completed_quests = []
      @recent_quests = []
    end
  end




  def create
    friend = User.find(params[:friend_id])

    daily_sent_requests = current_user.friendships.where(created_at: Time.current.all_day).count
    if daily_sent_requests >= Friendship::MAX_DAILY_SENT
      redirect_back fallback_location: friends_path, alert: "Tu as atteint la limite de #{Friendship::MAX_DAILY_SENT} demandes d'amis aujourd'hui."
      return
    end

    if friend == current_user
      redirect_back fallback_location: friends_path, alert: "Tu ne peux pas t'ajouter en ami."
      return
    end

    if Friendship.pending.where(friend: friend).count >= Friendship::MAX_PENDING_RECEIVED
      redirect_back fallback_location: friends_path, alert: "Ce joueur a atteint le nombre max de demandes d'amis en attente (#{Friendship::MAX_PENDING_RECEIVED})."
      return
    end

    existing = Friendship.where(user: current_user, friend: friend)
                 .or(Friendship.where(user: friend, friend: current_user))
                 .exists?

    if existing
      redirect_back fallback_location: friends_path, alert: "Une relation existe déjà avec cet utilisateur."
    else
      friendship = Friendship.new(user: current_user, friend: friend, status: "pending")

      if friendship.save
        ProductAnalytics.track(user: current_user, event_name: "friend_request_sent", metadata: { friend_id: friend.id })
        InAppNotification.create!(
          user: friend,
          kind: "friend_request",
          title: "Nouvelle demande d'ami",
          body: "#{current_user.pseudo} t'a envoye une demande.",
          cta_path: "/friends"
        )
        redirect_back fallback_location: friends_path, notice: "Demande d'ami envoyee !"
      else
        redirect_back fallback_location: friends_path, alert: "Erreur : #{friendship.errors.full_messages.join(", ")}"
      end
    end
  end
  def search
    if params[:query].present?
      @users = User.where("pseudo ILIKE ?", "%#{params[:query]}%")
                   .where.not(id: current_user.id)
    else
      @users = []
    end
  end


  def accept
    friendship = Friendship.find_by(user_id: params[:id], friend: current_user, status: "pending") ||
                 Friendship.find_by(user: current_user, friend_id: params[:id], status: "pending")

    if friendship
      friendship.update(status: "accepted")
      friend = friendship.user == current_user ? friendship.friend : friendship.user
      ProductAnalytics.track(user: current_user, event_name: "friend_request_accepted", metadata: { friend_id: friend.id })
      InAppNotification.create!(
        user: friend,
        kind: "friend_accept",
        title: "Demande acceptee",
        body: "#{current_user.pseudo} a accepte ton invitation.",
        cta_path: "/friends"
      )
      flash[:notice] = "Amitié acceptée !"
    else
      flash[:alert] = "Aucune demande trouvée."
    end

    redirect_to friends_path
  end

  def reject
    friendship = Friendship.find_by(user_id: params[:id], friend: current_user, status: "pending") ||
                 Friendship.find_by(user: current_user, friend_id: params[:id], status: "pending")

    if friendship
      friendship.destroy
      flash[:notice] = "Demande refusée."
    else
      flash[:alert] = "Aucune demande trouvée."
    end

    redirect_to friends_path
  end


  def destroy
    friendship = Friendship.find_by(user: current_user, friend_id: params[:id]) ||
                 Friendship.find_by(user_id: params[:id], friend: current_user)

    if friendship
      friendship.destroy
      flash[:notice] = "Amitié supprimée avec succès."
    else
      flash[:alert] = "Impossible de supprimer cet ami."
    end

    redirect_to friends_path
  end
end
