class DashboardController < ApplicationController
  before_action :authenticate_user!  # 🔹 Empêche l’accès sans connexion

  def index
    @user_quests = current_user.user_quests.includes(:quest)
    @stats = current_user.user_stats.includes(:category)

    # Récupération des stats sous forme de hash pour le JS
    @stats_data = @stats.map { |stat| { name: stat.category.name, level: stat.level } }
    @total_level = @stats.sum(&:level) # Niveau total (somme des niveaux)
  end
end
