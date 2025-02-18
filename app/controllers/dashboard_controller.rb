class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user_quests = current_user.user_quests.includes(:quest)
    @stats = current_user.user_stats.includes(:category)

    # 🔥 Synchronisation des niveaux et XP
    @stats.each do |stat|
      recalculated_level, recalculated_xp = calculate_level_and_xp(stat.total_xp)

      # Mise à jour en base de données si nécessaire
      if stat.level != recalculated_level || stat.xp != recalculated_xp
        stat.update(level: recalculated_level, xp: recalculated_xp)
      end
    end

    # 🔥 Préparer les données pour le Radar Chart
    @stats_data = @stats.map do |stat|
      {
        name: stat.category.name,
        level: stat.level,
        xp: stat.xp,
        xp_needed: xp_needed_for_next_level(stat.level)
      }
    end

    @total_level = @stats.sum(&:level)

    # 🔥 Répondre avec JSON si format JSON demandé
    respond_to do |format|
      format.html # Rendu normal en HTML
      format.json { render json: @stats_data } # 🔥 JSON pour le Radar Chart
    end
  end

  private

  # 🔥 Fonction pour calculer le niveau et l'XP restant
  def calculate_level_and_xp(total_xp)
    level = 1
    xp_remaining = total_xp
    xp_needed_for_next = xp_needed_for_next_level(level)

    while xp_remaining >= xp_needed_for_next
      xp_remaining -= xp_needed_for_next
      level += 1
      xp_needed_for_next = xp_needed_for_next_level(level)
    end

    [ level, xp_remaining ]
  end

  # 🔥 XP nécessaire pour le niveau suivant
  def xp_needed_for_next_level(level)
    case level
    when 1..10
      level * 100
    when 11..20
      (level**1.8 * 100).to_i
    when 21..30
      (level**1.7 * 100).to_i
    when 31..40
      (level**1.6 * 100).to_i
    when 41..50
      (level**1.5 * 100).to_i
    when 51..60
      (level**1.4 * 100).to_i
    when 61..70
      (level**1.3 * 100).to_i
    when 71..80
      (level**1.2 * 100).to_i
    when 81..90
      (level**1.1 * 100).to_i
    else
      (level**1.1 * 100).to_i # Niveau 91+
    end
  end
end
