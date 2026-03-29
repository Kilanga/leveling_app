class UsersController < ApplicationController
  before_action :authenticate_user!
  PSEUDO_CHANGE_COOLDOWN = 7.days
  PSEUDO_BANWORDS = %w[admin moderator root support staff].freeze

  def index
    @users = User.where.not(id: current_user.id).order(:pseudo)
  end

  def show
    @user = current_user
    TitleUnlocker.call(@user)

    @user_quests = @user.user_quests.where("completed_count > 0").includes(:quest).order(completed_count: :desc)
    @completed_quests_total = @user.user_quests.sum(:completed_count)
    @xp_this_week = @user.user_quests.where(completed: true, updated_at: Time.current.all_week).joins(:quest).sum("quests.xp")
    @challenge_history = FriendChallenge.where("challenger_id = :id OR challenged_id = :id", id: @user.id)
                      .where(status: "completed")
                      .includes(:challenger, :challenged, :winner)
                      .order(updated_at: :desc)
                      .limit(5)
    @owned_titles = @user.shop_items.where(item_type: "title").order(name: :asc)
    @owned_frames = @user.shop_items.where(item_type: "profile_frame").order(name: :asc)
    @owned_themes = @user.shop_items.where(item_type: "xp_theme").order(name: :asc)
    @owned_cards = @user.shop_items.where(item_type: "profile_card").order(name: :asc)
    @unlockable_title_progress = TitleUnlocker.progress_for(@user)
    @common_unlockable_titles = @unlockable_title_progress.select { |entry| entry[:rarity] == "common" }
    @prestige_unlockable_titles = @unlockable_title_progress.reject { |entry| entry[:rarity] == "common" }
    @next_pseudo_change_at = next_pseudo_change_at(@user)
  end

  def update_pseudo
    new_pseudo = params.dig(:user, :pseudo).to_s.strip
    return redirect_to user_profile_path, alert: "Pseudo invalide." if new_pseudo.blank?

    if pseudo_change_locked?(current_user)
      available_at = current_user.pseudo_last_changed_at + PSEUDO_CHANGE_COOLDOWN
      return redirect_to user_profile_path, alert: "Tu pourras rechanger ton pseudo le #{available_at.strftime('%d/%m/%Y')}"
    end

    if banned_pseudo?(new_pseudo)
      return redirect_to user_profile_path, alert: "Ce pseudo n'est pas autorise."
    end

    if new_pseudo.casecmp(current_user.pseudo.to_s).zero?
      return redirect_to user_profile_path, notice: "Ce pseudo est deja le tien."
    end

    if current_user.update(pseudo: new_pseudo, pseudo_last_changed_at: Time.current)
      redirect_to user_profile_path, notice: "Pseudo mis a jour."
    else
      redirect_to user_profile_path, alert: current_user.errors.full_messages.to_sentence
    end
  end

  def activate_title
    item = current_user.shop_items.find_by(id: params[:shop_item_id], item_type: "title")
    return redirect_to user_profile_path, alert: "Titre introuvable." unless item

    current_user.activate_title(item)
    redirect_to user_profile_path, notice: "Titre activé."
  end

  def deactivate_title
    current_user.deactivate_title
    redirect_to user_profile_path, notice: "Titre retiré."
  end

  def activate_avatar
    item = current_user.shop_items.find_by(id: params[:shop_item_id], item_type: "cosmetic")
    return redirect_to new_purchase_path, alert: "Avatar introuvable." unless item

    if current_user.activate_avatar(item)
      redirect_to new_purchase_path, notice: "Avatar equipe avec succes."
    else
      redirect_to new_purchase_path, alert: "Impossible d'equiper cet avatar."
    end
  end

  def activate_cosmetic
    cosmetic_type = params[:cosmetic_type].to_s.presence
    return redirect_to user_profile_path, alert: "Type de cosmetic invalide." unless cosmetic_type.in?(%w[profile_frame xp_theme profile_card])

    item = current_user.shop_items.find_by(id: params[:shop_item_id], item_type: cosmetic_type)
    return redirect_to user_profile_path, alert: "Cosmetic introuvable." unless item

    if current_user.activate_cosmetic(item)
      redirect_to user_profile_path, notice: "Cosmetic active avec succes."
    else
      redirect_to user_profile_path, alert: "Impossible d'attiver ce cosmetic."
    end
  end

  def update_profile_card_text
    new_text = params[:profile_card_text].to_s.strip.slice(0, 100)

    if current_user.update(profile_card_custom_text: new_text)
      redirect_to user_profile_path, notice: "Texte de carte mise a jour."
    else
      redirect_to user_profile_path, alert: "Impossible de mettre a jour le texte."
    end
  end

  def complete_profile
    @user = current_user
  end

  def update_profile
    @user = current_user
    if @user.update(profile_params.merge(profile_completed: true))
      redirect_to root_path
    else
      render :complete_profile, status: :unprocessable_entity
    end
  end

  private

  def pseudo_change_locked?(user)
    user.pseudo_last_changed_at.present? && user.pseudo_last_changed_at > PSEUDO_CHANGE_COOLDOWN.ago
  end

  def next_pseudo_change_at(user)
    return nil unless pseudo_change_locked?(user)

    user.pseudo_last_changed_at + PSEUDO_CHANGE_COOLDOWN
  end

  def banned_pseudo?(pseudo)
    lowered = pseudo.downcase
    PSEUDO_BANWORDS.any? { |word| lowered.include?(word) }
  end

  def profile_params
    params.require(:user).permit(:pseudo, :avatar)
  end
end
