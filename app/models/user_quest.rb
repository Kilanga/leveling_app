class UserQuest < ApplicationRecord
  belongs_to :user
  belongs_to :quest

  validates :progress, numericality: { greater_than_or_equal_to: 0 }

  def complete!
    return if completed?

    update(completed: true, completed_count: completed_count + 1)

    # Ajouter l'XP au joueur
    stat = user.user_stats.find_or_create_by(category: quest.category)
    stat.total_xp ||= 0
    stat.total_xp += quest.xp * user.xp_multiplier

    # Gestion du niveau
    while stat.total_xp >= xp_needed_until_level(stat.level + 1)
      stat.level += 1
    end

    # Calcul de l'XP dans le niveau actuel
    stat.xp = stat.total_xp - xp_needed_until_level(stat.level)

    stat.save

    # Réinitialiser la quête pour être disponible à nouveau
    update(progress: 0, completed: false)
  end
end
