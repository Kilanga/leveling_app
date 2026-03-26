class FriendsController < ApplicationController
  before_action :authenticate_user!

  def index
    sent_accepted = current_user.friendships.accepted.includes(:friend).map(&:friend)
    received_accepted = Friendship.accepted.where(friend: current_user).includes(:user).map(&:user)
    @friends = (sent_accepted + received_accepted).uniq

    @pending_sent_requests = current_user.friendships.pending.includes(:friend).map(&:friend)
    @pending_received_requests = Friendship.pending.where(friend: current_user).includes(:user).map(&:user)
  end




  def create
    friend = User.find(params[:friend_id])
    if friend == current_user
      redirect_to friends_path, alert: "Tu ne peux pas t'ajouter en ami."
      return
    end

    existing = Friendship.where(user: current_user, friend: friend)
                 .or(Friendship.where(user: friend, friend: current_user))
                 .exists?

    if existing
      redirect_to friends_path, alert: "Une relation existe déjà avec cet utilisateur."
    else
      friendship = Friendship.new(user: current_user, friend: friend, status: "pending")

      if friendship.save
        redirect_to friends_path, notice: "Demande d'ami envoyée !"
      else
        redirect_to friends_path, alert: "Erreur : #{friendship.errors.full_messages.join(", ")}"
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
