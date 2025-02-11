class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  def index
    @users = User.all
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "Utilisateur mis à jour."
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:xp, :admin, :coins)
  end

  def check_admin
    redirect_to root_path, alert: "Accès interdit." unless current_user.admin?
  end
end
