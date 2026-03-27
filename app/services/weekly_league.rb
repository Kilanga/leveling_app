class WeeklyLeague
  TIERS = ["Bronze", "Silver", "Gold"].freeze

  class << self
    def standings(users)
      ranked = users.sort_by { |u| -weekly_xp(u) }
      ranked.map.with_index(1) do |user, rank|
        { user: user, rank: rank, weekly_xp: weekly_xp(user), tier: tier_for_rank(rank, ranked.size) }
      end
    end

    def tier_for_rank(rank, size)
      return "Bronze" if size <= 0

      percentile = rank.to_f / size
      return "Gold" if percentile <= 0.2
      return "Silver" if percentile <= 0.6

      "Bronze"
    end

    def weekly_xp(user)
      user.user_quests.where(completed: true, updated_at: Time.current.all_week).joins(:quest).sum("quests.xp")
    end
  end
end
