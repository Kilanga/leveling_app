class UserWeeklyQuestsController < ApplicationController
  before_action :authenticate_user!

  def update
    user_weekly_quest = current_user.user_weekly_quests.find(params[:id])
    if params[:action_type] == "complete" && !user_weekly_quest.completed?
      user_weekly_quest.update!(completed: true)
  
      weekly_quest = user_weekly_quest.weekly_quest
      current_user.update!(xp: current_user.xp + weekly_quest.xp_reward)
  
      # 🔥 Mise à jour de l'XP de la catégorie du joueur
      user_stat = current_user.user_stats.find_or_create_by(category: weekly_quest.category)
      user_stat.update!(xp: user_stat.xp + weekly_quest.xp_reward)
  
      flash[:success] = "✅ Quête complétée ! XP ajouté : #{weekly_quest.xp_reward}"
    end
  
    redirect_to dashboard_path
  end
  
end
