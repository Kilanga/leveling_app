# Validation directe d'une quête du jour imposée par le Système
# depuis le dashboard (sans passer par le suivi manuel des quêtes).
class SystemQuestsController < ApplicationController
  before_action :authenticate_user!

  def complete
    return if abuse_blocked?(dashboard_path)

    assignment = current_user.system_quest_assignments
      .for_day(Time.zone.today)
      .find(params[:id])

    if assignment.completed?
      redirect_to dashboard_path, alert: I18n.t("flash.system_quests.already_completed")
      return
    end

    user_quest = current_user.user_quests.find_or_initialize_by(quest: assignment.quest)
    if user_quest.new_record?
      user_quest.assign_attributes(progress: 0, completed: false, active: true, completed_count: 0)
      user_quest.save!
    elsif !user_quest.active?
      if user_quest.locked_until_daily_reset?
        redirect_to dashboard_path, alert: I18n.t("flash.quests.not_available")
        return
      end

      user_quest.update!(active: true, completed: false)
    end

    weekly_xp_before = WeeklyLeague.weekly_xp(current_user)
    gained_xp = XpAwarder.complete_user_quest!(user_quest)

    unless gained_xp
      redirect_to dashboard_path, alert: I18n.t("errors.messages.quest_not_active")
      return
    end

    if current_user.faction.present?
      FactionInfluence.add_points!(faction: current_user.faction, points: 1)
      FactionContribution.add_points!(faction: current_user.faction, user: current_user, points: 1)
      FactionBoss.check!(current_user.faction)
    end
    UserDailyContract.progress_for_user!(current_user)
    system_result = SystemQuestBoard.register_completion!(current_user, assignment.quest)
    WeeklyStreakTracker.register_completion!(current_user)
    FriendOvertakeNotifier.call(current_user, xp_before: weekly_xp_before)
    ProductAnalytics.track(
      user: current_user,
      event_name: "system_quest_completed",
      metadata: { quest_id: assignment.quest_id, xp: gained_xp, perfect_day: system_result&.perfect_day == true }
    )

    notice = I18n.t("flash.system_quests.quest_completed", xp: gained_xp)
    if system_result&.perfect_day
      notice += " " + I18n.t("flash.system_quests.perfect_day", xp: system_result.bonus_xp, fragments: system_result.bonus_fragments)
    end

    redirect_to dashboard_path, notice: notice
  end
end
