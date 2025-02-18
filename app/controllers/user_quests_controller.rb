class UserQuestsController < ApplicationController
  before_action :authenticate_user!

  def create
    quest = Quest.find(params[:quest_id])
    user_quest = current_user.user_quests.find_or_initialize_by(quest: quest)

    if user_quest.new_record?
      user_quest.assign_attributes(progress: 0, completed: false, active: true, completed_count: 0)
      user_quest.save
      flash[:notice] = "Quête ajoutée avec succès !"

    elsif !user_quest.active?
      # Si la quête était désactivée, la réactiver et réinitialiser `completed: false`
      user_quest.update(active: true, completed: false)
      flash[:notice] = "Quête réactivée avec succès !"

    else
      flash[:alert] = "Tu suis déjà cette quête."
    end

    redirect_to quests_path
  end

  def destroy
    user_quest = current_user.user_quests.find(params[:id])

    if user_quest.update(active: false)
      flash[:notice] = "Quête retirée avec succès."
    else
      flash[:alert] = "Impossible de retirer la quête."
    end

    redirect_to quests_path
  end

  def update
    @user_quest = current_user.user_quests.find(params[:id])

    case params[:action_type]
    when "complete"
      ActiveRecord::Base.transaction do
        # Incrémentation du compteur de complétion
        @user_quest.increment!(:completed_count)

        # Ajouter l'XP
        stat = current_user.user_stats.find_or_create_by(category: @user_quest.quest.category)
        stat.update(total_xp: (stat.total_xp || 0) + @user_quest.quest.xp)

        # Recalcul du niveau
        level = 1
        xp_remaining = stat.total_xp
        xp_needed_for_next = xp_needed_for_next_level(level)

        while xp_remaining >= xp_needed_for_next
          xp_remaining -= xp_needed_for_next
          level += 1
          xp_needed_for_next = xp_needed_for_next_level(level)
        end

        # Mettre à jour le niveau et l'XP restante
        stat.update(level: level, xp: xp_remaining)

        # Désactiver la quête
        @user_quest.update(active: false)
      end

      redirect_to root_path, notice: "Quête complétée ! XP ajouté."
    when "unfollow"
      @user_quest.update(active: false)
      redirect_to root_path, notice: "Quête supprimée de votre liste."
    end
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
