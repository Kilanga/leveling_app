class UserWeeklyQuestsController < ApplicationController
  before_action :authenticate_user!

  def update
    user_weekly_quest = current_user.user_weekly_quests.find(params[:id])
    if params[:action_type] == "complete"
      gained_xp = XpAwarder.complete_weekly_quest!(user_weekly_quest)
      if gained_xp
        streak = WeeklyStreakTracker.register_completion!(current_user)
        ProductAnalytics.track(
          user: current_user,
          event_name: "weekly_quest_completed",
          metadata: { weekly_quest_id: user_weekly_quest.weekly_quest_id, xp: gained_xp, streak: streak }
        )
        flash[:success] = I18n.t('flash.weekly_quests.quest_completed', xp: gained_xp)
      else
        flash[:alert] = I18n.t('flash.weekly_quests.already_completed')
      end
    end

    redirect_to dashboard_path
  end
end
