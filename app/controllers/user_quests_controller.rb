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
    @user_quest.completed_count ||= 0
    @user_quest.completed_count += 1
    @user_quest.save

    # Ajoute l'XP au joueur
    stat = current_user.user_stats.find_or_create_by(category: @user_quest.quest.category)
    stat.total_xp ||= 0  # On s'assure d'avoir une variable pour l'XP totale accumulée
    stat.total_xp += @user_quest.quest.xp * current_user.xp_multiplier

    # Gestion du niveau
    while stat.total_xp >= xp_needed_until_level(stat.level + 1)
      stat.level += 1
    end

    # Calcul de l'XP dans le niveau actuel
    stat.xp = stat.total_xp - xp_needed_until_level(stat.level)
    stat.save

    # Réinitialiser la quête pour être disponible à nouveau
    @user_quest.update(progress: 0, completed: false)

    redirect_to root_path, notice: "Quête complétée, XP ajouté !"
  end

  def create
    quest = Quest.find(params[:quest_id])
    user_quest = current_user.user_quests.find_or_initialize_by(quest: quest)

    if user_quest.new_record?
      user_quest.progress = 0
      user_quest.completed = false
      user_quest.completed_count ||= 0
      user_quest.save
      flash[:notice] = "Quête ajoutée avec succès !"
    else
      user_quest.destroy
      flash[:alert] = "Quête retirée."
    end

    redirect_to quests_path
  end

  private

  # Calcule l'XP totale nécessaire pour atteindre un niveau donné
  def xp_needed_until_level(level)
    (1...level).sum { |lvl| xp_needed_for_next_level(lvl) }
  end

  # Fonction pour calculer l'XP nécessaire en fonction du niveau
  def xp_needed_for_next_level(level)
    case level
    when 1..10
      level * 100
    when 11..20
      (level**1.8 * 100).to_i
    when 21..30
      (level**1.7 * 100).to_i
    when 31..40
      (level**1.6 * 100).to_i
    when 41..50
      (level**1.5 * 100).to_i
    when 51..60
      (level**1.4 * 100).to_i
    when 61..70
      (level**1.3 * 100).to_i
    when 71..80
      (level**1.2 * 100).to_i
    when 81..90
      (level**1.1 * 100).to_i
    else
      (level**1.1 * 100).to_i # Niveau 91+
    end
  end
end
