class UserWeeklyQuestsController < ApplicationController
  before_action :authenticate_user!

  def update
    user_weekly_quest = current_user.user_weekly_quests.find(params[:id])
    if params[:action_type] == "complete"
      if XpAwarder.complete_weekly_quest!(user_weekly_quest)
        flash[:success] = "Quête complétée ! XP ajouté : #{user_weekly_quest.weekly_quest.xp_reward}"
      else
        flash[:alert] = "Cette quête hebdomadaire est déjà validée."
      end
    end

    redirect_to dashboard_path
  end
end
