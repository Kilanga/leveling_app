# Le Système : chaque nuit, il impose 3-4 quêtes du jour à chaque chasseur.
# La sélection est pondérée vers les catégories faibles du joueur (user_stats
# les plus bas) et la difficulté est alignée sur son rang de chasseur.
# Idempotent : relancer l'assignation le même jour ne change rien.
class SystemQuestAssigner
  MIN_QUESTS = 3
  MAX_QUESTS = 4

  # Difficultés éligibles par rang : autour du rang du joueur,
  # avec toujours une porte d'entrée un cran en dessous.
  RANK_DIFFICULTIES = {
    "E" => %w[E D],
    "D" => %w[E D C],
    "C" => %w[D C B],
    "B" => %w[C B A],
    "A" => %w[B A S],
    "S" => %w[A S]
  }.freeze

  class << self
    # Point d'entrée du job récurrent de minuit.
    def assign_all!(date: Time.zone.today)
      User.find_each do |user|
        assign_for!(user, date: date)
      rescue StandardError => e
        Rails.logger.error("[SystemQuestAssigner] user=#{user.id} #{e.class}: #{e.message}")
      end
    end

    # Assigne les quêtes du jour d'un joueur. Retourne les assignations du jour.
    def assign_for!(user, date: Time.zone.today)
      existing = user.system_quest_assignments.for_day(date).includes(quest: :category)
      return existing.to_a if existing.size >= MIN_QUESTS

      quests = pick_quests(user, date: date, count: quest_count_for(user, date))

      quests.map do |quest|
        user.system_quest_assignments.find_or_create_by!(quest: quest, assigned_on: date)
      rescue ActiveRecord::RecordNotUnique
        user.system_quest_assignments.find_by!(quest: quest, assigned_on: date)
      end
    end

    private

    # 3 ou 4 quêtes, stable pour un joueur/jour donné.
    def quest_count_for(user, date)
      MIN_QUESTS + (Digest::MD5.hexdigest("#{user.id}-#{date.iso8601}").to_i(16) % (MAX_QUESTS - MIN_QUESTS + 1))
    end

    def pick_quests(user, date:, count:)
      allowed = RANK_DIFFICULTIES.fetch(HunterRank.for_user(user)[:letter], %w[E D])
      pool = Quest.with_difficulty(allowed).includes(:category).to_a
      pool = Quest.includes(:category).to_a if pool.empty?
      return [] if pool.empty?

      yesterday_ids = user.system_quest_assignments.for_day(date - 1.day).pluck(:quest_id)
      fresh_pool = pool.reject { |quest| yesterday_ids.include?(quest.id) }
      pool = fresh_pool if fresh_pool.size >= count

      weights = category_weights(user)
      rng = Random.new(Digest::MD5.hexdigest("system-#{user.id}-#{date.iso8601}").to_i(16) % (2**32))

      picked = []
      count.times do
        candidates = pool - picked
        break if candidates.empty?

        # Un maximum d'une quête par catégorie tant que c'est possible.
        used_category_ids = picked.map(&:category_id)
        spread = candidates.reject { |quest| used_category_ids.include?(quest.category_id) }
        candidates = spread if spread.any?

        picked << weighted_sample(candidates, weights, rng)
      end

      picked
    end

    # Poids inverse au niveau : plus la catégorie est faible, plus elle
    # a de chances d'être travaillée. Catégorie inconnue = niveau 1.
    def category_weights(user)
      levels = user.user_stats.pluck(:category_id, :level).to_h
      Category.pluck(:id).index_with { |category_id| 1.0 / (levels.fetch(category_id, 1) + 1) }
    end

    def weighted_sample(candidates, weights, rng)
      total = candidates.sum { |quest| weights.fetch(quest.category_id, 1.0) }
      target = rng.rand * total

      candidates.each do |quest|
        target -= weights.fetch(quest.category_id, 1.0)
        return quest if target <= 0
      end

      candidates.last
    end
  end
end
