class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    ensure_global_weekly_quest!
    attach_current_user_to_active_weekly_quests!

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

  private

  def ensure_global_weekly_quest!
    return if WeeklyQuest.where("valid_until >= ?", Time.current).exists?

    source_quest = Quest.includes(:category).order("RANDOM()").first
    return unless source_quest

    WeeklyQuest.create!(
      title: "Hebdo: #{source_quest.title}",
      description: source_quest.description.presence || "Complete cette quete hebdomadaire pour un gros bonus.",
      xp_reward: [source_quest.xp.to_i * 2, 300].max,
      category: source_quest.category,
      valid_until: 7.days.from_now
    )
  end

  def attach_current_user_to_active_weekly_quests!
    WeeklyQuest.where("valid_until >= ?", Time.current).find_each do |weekly_quest|
      current_user.user_weekly_quests.find_or_create_by!(weekly_quest: weekly_quest)
    end
  end
end
