class UserQuestsController < ApplicationController
  before_action :authenticate_user!

  def update
    @user_quest = current_user.user_quests.find(params[:id])

    if @user_quest.completed
      redirect_to root_path, alert: "Cette quête est déjà complétée."
      return
    end

    @user_quest.progress = 100
    @user_quest.completed = true
    @user_quest.save

    # Ajoute l'XP au joueur
    stat = current_user.user_stats.find_or_create_by(category: @user_quest.quest.category)
    stat.xp += @user_quest.quest.xp * current_user.xp_multiplier

    # Passage de niveau si XP suffisant
    xp_needed = stat.level * 100
    if stat.xp >= xp_needed
      stat.xp -= xp_needed
      stat.level += 1
    end

    stat.save

    redirect_to root_path, notice: "Quête complétée, XP ajouté !"
  end
end
