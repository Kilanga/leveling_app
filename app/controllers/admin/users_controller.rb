class Admin::UsersController < ApplicationController
  before_action :authenticate_admin!

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
    params.require(:user).permit(:xp, :coins)
  end
end
