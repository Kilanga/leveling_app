class XpAwarder
  class << self
    def complete_user_quest!(user_quest)
      ActiveRecord::Base.transaction do
        user_quest.lock!
        return false unless user_quest.active?

        user_quest.increment!(:completed_count)

        apply_category_xp!(
          user: user_quest.user,
          category: user_quest.quest.category,
          xp_amount: user_quest.quest.xp * user_quest.user.xp_multiplier
        )

        user_quest.update!(active: false, completed: true)
        TitleUnlocker.call(user_quest.user)
      end

      true
    end

    def complete_weekly_quest!(user_weekly_quest)
      ActiveRecord::Base.transaction do
        user_weekly_quest.lock!
        return false if user_weekly_quest.completed?

        weekly_quest = user_weekly_quest.weekly_quest
        user = user_weekly_quest.user

        user_weekly_quest.update!(completed: true)
        user.increment!(:xp, weekly_quest.xp_reward)

        apply_category_xp!(
          user: user,
          category: weekly_quest.category,
          xp_amount: weekly_quest.xp_reward * user.xp_multiplier
        )

        TitleUnlocker.call(user)
      end

      true
    end

    private

    def apply_category_xp!(user:, category:, xp_amount:)
      user_stat = user.user_stats.lock.find_or_create_by!(category: category) do |stat|
        stat.level = 1
        stat.xp = 0
        stat.total_xp = 0
      end

      total_xp = user_stat.total_xp.to_i + xp_amount.to_i
      level, xp_in_level = XpCalculator.calculate_level_and_xp(total_xp)

      user_stat.update!(
        total_xp: total_xp,
        level: level,
        xp: xp_in_level
      )
    end
  end
end
