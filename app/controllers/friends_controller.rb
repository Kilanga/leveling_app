class FriendsController < ApplicationController
  before_action :authenticate_user!

  def index
    @friends = (current_user.friendships.where(status: "accepted").map(&:friend) +
                Friendship.where(friend: current_user, status: "accepted").map(&:user)).uniq || []

    @pending_sent_requests = current_user.friendships.where(status: "pending").map(&:friend) || []
    @pending_received_requests = Friendship.where(friend: current_user, status: "pending").map(&:user) || []

    Rails.logger.info "👀 Nombre d'amis acceptés trouvés : #{@friends.count}"
    Rails.logger.info "📩 Nombre de demandes envoyées en attente : #{@pending_sent_requests.count}"
    Rails.logger.info "📥 Nombre de demandes reçues en attente : #{@pending_received_requests.count}"
  end




  def create
    friend = User.find(params[:friend_id])
    friendship = Friendship.new(user: current_user, friend: friend, status: "pending")

    Rails.logger.info "🟢 Tentative de création d'une amitié entre #{current_user.pseudo} et #{friend.pseudo}"

    if friendship.save
      Rails.logger.info "✅ Demande d'ami enregistrée en base avec ID #{friendship.id}"
      redirect_to friends_path, notice: "Demande d'ami envoyée !"
    else
      Rails.logger.error "❌ Erreur lors de l'enregistrement de la demande d'ami : #{friendship.errors.full_messages.join(", ")}"
      redirect_to friends_path, alert: "Erreur : #{friendship.errors.full_messages.join(", ")}"
    end
  end






  def search
    @users = User.where("pseudo ILIKE ?", "%#{params[:query]}%") if params[:query].present?
  end

  def send_request
    Rails.logger.info "🔵 Début de send_request - Utilisateur: #{current_user.pseudo}"

    friend = User.find_by(id: params[:friend_id])

    if friend.nil?
      Rails.logger.error "❌ ERREUR : L'utilisateur avec l'ID #{params[:friend_id]} n'existe pas !"
      redirect_to friends_path, alert: "Utilisateur introuvable."
      return
    end

    Rails.logger.info "🟢 Utilisateur ciblé pour l'amitié : #{friend.pseudo}"

    if Friendship.exists?(user: current_user, friend: friend)
      Rails.logger.info "❌ Une demande existe déjà entre #{current_user.pseudo} et #{friend.pseudo}"
    else
      friendship = Friendship.create(user: current_user, friend: friend, status: "pending")

      if friendship.persisted?
        Rails.logger.info "✅ Demande d'ami créée avec succès : #{current_user.pseudo} → #{friend.pseudo}"
      else
        Rails.logger.error "⚠️ Erreur lors de la création de la demande d'ami entre #{current_user.pseudo} et #{friend.pseudo}"
        Rails.logger.error "🔴 Erreurs : #{friendship.errors.full_messages.join(', ')}"
      end
    end

    redirect_to friends_path, notice: "Demande envoyée !"
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
