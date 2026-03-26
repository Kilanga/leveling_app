class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.where.not(id: current_user.id).order(:pseudo)
  end

  def show
    @user = current_user
    @user_quests = @user.user_quests.where("completed_count > 0").includes(:quest).order(completed_count: :desc)
    @user_badges = @user.user_badges.includes(:badge).order(awarded_at: :desc)
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

  def profile_params
    params.require(:user).permit(:pseudo, :avatar)
  end
end