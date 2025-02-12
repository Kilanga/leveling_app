class DashboardController < ApplicationController
  before_action :authenticate_user!  # 🔹 Empêche l’accès sans connexion

  def index
    @user_quests = current_user.user_quests.includes(:quest)
    @stats = current_user.user_stats.includes(:category)
  end
end
