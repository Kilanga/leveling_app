class DashboardController < ApplicationController
  before_action :authenticate_user!

  WEEKLY_REUSE_WINDOW = 6.weeks

  def index
    active_weekly_quest = ensure_single_active_global_weekly_quest!
    attach_current_user_to_active_weekly_quest!(active_weekly_quest)

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
    @weekly_streak_count = current_user.weekly_streak_count.to_i
    @weekly_streak_last_completed_on = current_user.weekly_streak_last_completed_on

    league_users = User.includes(:user_quests).limit(100)
    @league_standings = WeeklyLeague.standings(league_users).first(10)
    @my_league_entry = @league_standings.find { |entry| entry[:user].id == current_user.id } ||
               WeeklyLeague.standings([current_user]).first
    @daily_target = 2
    @completed_today_count = current_user.user_quests
      .where(completed: true)
      .where(updated_at: Time.zone.today.all_day)
      .count
    @daily_progress_percent = [(@completed_today_count.to_f / @daily_target * 100).round, 100].min

    respond_to do |format|
      format.html
      format.json { render json: @stats_data }
    end
  end

  private

  def ensure_single_active_global_weekly_quest!
    active_quests = WeeklyQuest.where("valid_until >= ?", Time.current).order(valid_until: :desc, created_at: :desc)
    current_active = active_quests.first

    unless current_active
      recent_titles = WeeklyQuest.where("created_at >= ?", WEEKLY_REUSE_WINDOW.ago)
                                 .pluck(:title)
                                 .map { |title| title.to_s.sub(/\AHebdo:\s*/, "") }
                                 .uniq

      source_scope = Quest.includes(:category)
      source_scope = source_scope.where.not(title: recent_titles) if recent_titles.any?

      source_quest = source_scope.order(Arel.sql("RANDOM()")).first
      source_quest ||= Quest.includes(:category).order(Arel.sql("RANDOM()")).first
      return nil unless source_quest

      current_active = WeeklyQuest.create!(
        title: "Hebdo: #{source_quest.title}",
        description: source_quest.description.presence || "Complete cette quete hebdomadaire pour un gros bonus.",
        xp_reward: [source_quest.xp.to_i * 2, 300].max,
        category: source_quest.category,
        valid_until: 7.days.from_now
      )
    end

    duplicate_ids = active_quests.where.not(id: current_active.id).pluck(:id)
    if duplicate_ids.any?
      WeeklyQuest.where(id: duplicate_ids).update_all(valid_until: 1.second.ago)
    end

    current_active
  end

  def attach_current_user_to_active_weekly_quest!(weekly_quest)
    return unless weekly_quest

    current_user.user_weekly_quests.find_or_create_by!(weekly_quest: weekly_quest)
  end
end
