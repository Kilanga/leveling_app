class StatsController < ApplicationController
  WEEKS_SHOWN = 8

  def show
    weeks = (0...WEEKS_SHOWN).map { |i| (Time.current - i.weeks).all_week }.reverse

    completed_scope = current_user.user_quests.where(completed: true)
    @weekly_series = weeks.map do |range|
      {
        label: I18n.l(range.first.to_date, format: :short),
        xp: completed_scope.where(updated_at: range).joins(:quest).sum("quests.xp"),
        completions: completed_scope.where(updated_at: range).count
      }
    end

    @stats = current_user.user_stats.includes(:category).order(total_xp: :desc)
    @total_level = @stats.sum(&:level)
    @total_xp = @stats.sum(&:total_xp)
    @completed_total = current_user.user_quests.sum(:completed_count)
    @current_streak = current_user.weekly_streak_count
    @best_week = @weekly_series.max_by { |w| w[:xp] }
  end
end
