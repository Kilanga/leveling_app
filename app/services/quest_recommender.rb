class QuestRecommender
  DEFAULT_LIMIT = 4

  class << self
    def call(user:, limit: DEFAULT_LIMIT, scope: Quest.all)
      active_quest_ids = user.user_quests.where(active: true).pluck(:quest_id)
      candidate_quests = scope.includes(:category).where.not(id: active_quest_ids).to_a
      return [] if candidate_quests.empty?

      context = recommendation_context_for(user)

      ranked = candidate_quests.map do |quest|
        score, reason = score_for(quest: quest, context: context)
        { quest: quest, score: score, reason: reason }
      end

      ranked
        .sort_by { |entry| [ -entry[:score], entry[:quest].xp.to_i, entry[:quest].title.to_s ] }
        .first(limit)
    end

    private

    def recommendation_context_for(user)
      recent_completions = user.user_quests
        .joins(:quest)
        .where(completed: true)
        .order(updated_at: :desc)
        .limit(8)

      recent_xp_values = recent_completions.pluck("quests.xp").map(&:to_i).select { |xp| xp.positive? }

      {
        target_xp: median(recent_xp_values),
        focus_category_ids: user.onboarding_category_ids.first(3),
        strongest_category_ids: user.user_stats.order(total_xp: :desc).limit(2).pluck(:category_id),
        growth_category_ids: user.user_stats.order(total_xp: :asc).limit(2).pluck(:category_id),
        recent_category_ids: recent_completions.pluck("quests.category_id").uniq.first(2),
        completed_counts_by_quest_id: user.user_quests.where("completed_count > 0").pluck(:quest_id, :completed_count).to_h
      }
    end

    def score_for(quest:, context:)
      score = 0
      reason = "Bon equilibre effort/recompense"

      if context[:focus_category_ids].include?(quest.category_id)
        score += 28
        reason = "Dans tes categories prioritaires"
      elsif context[:strongest_category_ids].include?(quest.category_id)
        score += 18
        reason = "Tu progresses deja bien dans cette categorie"
      elsif context[:growth_category_ids].include?(quest.category_id)
        score += 14
        reason = "Ideal pour faire monter une categorie en retard"
      elsif context[:recent_category_ids].include?(quest.category_id)
        score += 10
        reason = "Dans la continuite de tes quetes recentes"
      end

      if context[:target_xp]
        gap = (quest.xp.to_i - context[:target_xp]).abs
        fit_bonus = [ 22 - (gap / 6), 0 ].max
        score += fit_bonus
        reason = "Difficulte adaptee a ton rythme" if fit_bonus >= 16
      elsif quest.xp.to_i.between?(70, 220)
        score += 8
      end

      if quest.daily_featured?
        score += 8
        reason = "Mission du jour pour garder la cadence"
      end

      completed_count = context[:completed_counts_by_quest_id][quest.id].to_i
      score += 6 if completed_count.zero?
      score -= completed_count * 5

      [ score, reason ]
    end

    def median(values)
      return nil if values.empty?

      sorted = values.sort
      middle = sorted.length / 2
      return sorted[middle] if sorted.length.odd?

      ((sorted[middle - 1] + sorted[middle]) / 2.0).round
    end
  end
end
