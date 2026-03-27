class ProgressionXpEngine
  MAX_MULTIPLIER = 2.5
  ELITE_QUEST_XP_THRESHOLD = 300

  class << self
    def for_user_quest(user_quest)
      user = user_quest.user
      quest = user_quest.quest
      category_level = user.user_stats.find_by(category_id: quest.category_id)&.level.to_i
      streak_count = user_quest.completed_count.to_i

      build_gain(
        base_xp: quest.xp.to_i,
        multipliers: [
          user.xp_multiplier.to_f,
          streak_multiplier(streak_count),
          consistency_multiplier(user),
          catch_up_multiplier(category_level),
          elite_multiplier(quest.xp.to_i)
        ]
      )
    end

    def for_weekly_quest(user_weekly_quest)
      user = user_weekly_quest.user
      weekly_quest = user_weekly_quest.weekly_quest
      category_level = user.user_stats.find_by(category_id: weekly_quest.category_id)&.level.to_i

      build_gain(
        base_xp: weekly_quest.xp_reward.to_i,
        multipliers: [
          user.xp_multiplier.to_f,
          consistency_multiplier(user),
          catch_up_multiplier(category_level)
        ]
      )
    end

    private

    def build_gain(base_xp:, multipliers:)
      base_xp = [base_xp.to_i, 1].max
      total_multiplier = multipliers.compact.reduce(1.0) { |acc, value| acc * value.to_f }
      capped_multiplier = [total_multiplier, MAX_MULTIPLIER].min
      [(base_xp * capped_multiplier).round, 1].max
    end

    def streak_multiplier(streak_count)
      case streak_count
      when 20..Float::INFINITY
        1.3
      when 10..19
        1.2
      when 5..9
        1.1
      when 3..4
        1.05
      else
        1.0
      end
    end

    def consistency_multiplier(user)
      recent_completions = user.user_quests.where(completed: true, updated_at: 7.days.ago..Time.current).count

      case recent_completions
      when 14..Float::INFINITY
        1.2
      when 7..13
        1.1
      when 3..6
        1.05
      else
        1.0
      end
    end

    def catch_up_multiplier(category_level)
      case category_level.to_i
      when 0..2
        1.3
      when 3..5
        1.15
      when 6..8
        1.05
      else
        1.0
      end
    end

    def elite_multiplier(base_xp)
      base_xp >= ELITE_QUEST_XP_THRESHOLD ? 1.15 : 1.0
    end
  end
end
