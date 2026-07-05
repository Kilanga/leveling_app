class UserWeeklyQuestsController < ApplicationController
  before_action :authenticate_user!

  def update
    user_weekly_quest = current_user.user_weekly_quests.find(params[:id])
    if params[:action_type] == "complete"
      # Malus doux du Système : 2 jours ratés d'affilée gèlent le contrat
      # hebdo. Compléter une quête du jour lève le gel (aucune XP perdue).
      if SystemQuestBoard.weekly_progression_frozen?(current_user)
        redirect_to dashboard_path, alert: I18n.t("flash.system_quests.weekly_frozen")
        return
      end

      gained_xp = XpAwarder.complete_weekly_quest!(user_weekly_quest)
      if gained_xp
        streak = WeeklyStreakTracker.register_completion!(current_user)
        ProductAnalytics.track(
          user: current_user,
          event_name: "weekly_quest_completed",
          metadata: { weekly_quest_id: user_weekly_quest.weekly_quest_id, xp: gained_xp, streak: streak }
        )
        flash[:success] = I18n.t("flash.weekly_quests.quest_completed", xp: gained_xp)
      else
        flash[:alert] = I18n.t("flash.weekly_quests.already_completed")
      end
    end

    redirect_to dashboard_path
  end
end
