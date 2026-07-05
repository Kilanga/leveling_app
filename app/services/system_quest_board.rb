# Suivi des quêtes du Système : complétion, bonus « journée parfaite »
# et gel du contrat hebdo après 2 jours entièrement ratés.
#
# Principe roadmap V2 : on ne retire jamais d'XP. Le seul malus est un gel
# doux — la progression du contrat hebdo est bloquée tant que le chasseur
# n'a pas repris une quête du Système.
class SystemQuestBoard
  # V3 : moins de quêtes par jour, mais boucler la journée vaut plus cher.
  PERFECT_DAY_FRAGMENTS = 60
  PERFECT_DAY_XP_RATIO = 0.35 # bonus = 35% de l'XP des quêtes du jour

  Result = Struct.new(:assignment, :perfect_day, :bonus_xp, :bonus_fragments, keyword_init: true)

  class << self
    # À appeler quand un joueur valide une quête (peu importe le chemin).
    # Marque l'assignation du jour si la quête en fait partie, puis attribue
    # le bonus journée parfaite si tout est complété. Retourne un Result ou nil.
    def register_completion!(user, quest, date: Time.zone.today)
      assignment = user.system_quest_assignments.for_day(date).find_by(quest_id: quest.id)
      return nil unless assignment

      user.with_lock do
        assignment.reload
        assignment.update!(completed_at: Time.current) unless assignment.completed?

        todays = user.system_quest_assignments.for_day(date).includes(:quest)
        perfect = todays.any? && todays.all?(&:completed?)

        if perfect && user.last_perfect_day_on != date
          bonus_xp = (todays.sum { |entry| entry.quest.xp.to_i } * PERFECT_DAY_XP_RATIO).round
          bonus_category = weakest_category(user) || quest.category
          XpAwarder.award_bonus_xp!(user: user, category: bonus_category, xp_amount: bonus_xp)
          user.add_free_credits!(PERFECT_DAY_FRAGMENTS)
          user.update!(last_perfect_day_on: date)

          ProductAnalytics.track(
            user: user,
            event_name: "perfect_day_completed",
            metadata: { date: date.iso8601, bonus_xp: bonus_xp, bonus_fragments: PERFECT_DAY_FRAGMENTS }
          )

          return Result.new(assignment: assignment, perfect_day: true,
                            bonus_xp: bonus_xp, bonus_fragments: PERFECT_DAY_FRAGMENTS)
        end

        Result.new(assignment: assignment, perfect_day: false, bonus_xp: 0, bonus_fragments: 0)
      end
    end

    # Gel du contrat hebdo : actif si les 2 derniers jours avaient des quêtes
    # du Système et qu'aucune n'a été complétée, et que rien n'a encore été
    # repris aujourd'hui. Compléter une quête du jour lève le gel.
    def weekly_progression_frozen?(user, date: Time.zone.today)
      return false if user.system_quest_assignments.for_day(date).completed.exists?

      [ date - 1.day, date - 2.days ].all? do |day|
        assignments = user.system_quest_assignments.for_day(day)
        assignments.exists? && !assignments.completed.exists?
      end
    end

    private

    # La catégorie la plus faible du joueur reçoit le bonus : le Système
    # récompense le travail sur ses points faibles.
    def weakest_category(user)
      levels = user.user_stats.pluck(:category_id, :level).to_h
      weakest_id = Category.pluck(:id).min_by { |category_id| levels.fetch(category_id, 0) }
      weakest_id && Category.find(weakest_id)
    end
  end
end
