class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @weekly_quests = current_user.user_weekly_quests
      .joins(:weekly_quest)
      .where("weekly_quests.valid_until >= ?", Time.current)
      .includes(:weekly_quest)

    @user_quests = current_user.user_quests.includes(:quest)
    @stats = current_user.user_stats.includes(:category)

    @stats.each do |stat|
      recalculated_level, recalculated_xp = XpCalculator.calculate_level_and_xp(stat.total_xp)

      if stat.level != recalculated_level || stat.xp != recalculated_xp
        stat.update(level: recalculated_level, xp: recalculated_xp)
      end
    end

    @stats_data = @stats.map do |stat|
      {
        name: stat.category.name,
        level: stat.level,
        xp: stat.xp,
        xp_needed: XpCalculator.xp_needed_for_next_level(stat.level)
      }
    end

    @total_level = @stats.sum(&:level)

    respond_to do |format|
      format.html
      format.json { render json: @stats_data }
    end
  end
end
