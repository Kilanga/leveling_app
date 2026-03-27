class UserWeeklyQuestsController < ApplicationController
  before_action :authenticate_user!

  def update
    user_weekly_quest = current_user.user_weekly_quests.find(params[:id])
    if params[:action_type] == "complete"
      gained_xp = XpAwarder.complete_weekly_quest!(user_weekly_quest)
      if gained_xp
        flash[:success] = "Quete completee ! XP ajoute : #{gained_xp}"
      else
        flash[:alert] = "Cette quête hebdomadaire est déjà validée."
      end
    end

    redirect_to dashboard_path
  end
end
