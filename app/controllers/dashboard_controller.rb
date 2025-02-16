class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user_quests = current_user.user_quests.includes(:quest)
    @stats = current_user.user_stats.includes(:category)

    # 🔥 Recalcul dynamique des niveaux pour chaque catégorie
    @stats_data = @stats.map do |stat|
      level = 1
      xp_remaining = stat.xp
      xp_needed_for_next = xp_needed_for_next_level(level)

      while xp_remaining >= xp_needed_for_next
        xp_remaining -= xp_needed_for_next
        level += 1
        xp_needed_for_next = xp_needed_for_next_level(level)
      end

      {
        name: stat.category.name,
        level: level,
        xp: xp_remaining,
        xp_needed: xp_needed_for_next
      }
    end

    @total_level = @stats_data.sum { |stat| stat[:level] }

    # 🔥 Répondre avec JSON si format JSON demandé
    respond_to do |format|
      format.html # Rendu normal en HTML
      format.json { render json: @stats_data } # 🔥 JSON pour le Radar Chart
    end
  end

  private

  def xp_needed_for_next_level(level)
    case level
    when 1..10
      level * 100
    when 11..20
      (level**1.8 * 100).to_i
    when 21..30
      (level**1.7 * 100).to_i
    else
      (level**1.6 * 100).to_i
    end
  end
end
