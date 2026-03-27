class WeeklyLeague
  TIERS = ["Bronze", "Silver", "Gold", "Platinum", "Diamond"].freeze
  PROMOTION_RATE = 0.2
  ROOM_CAPACITY = 50

  class << self
    def standings(users, range: Time.current.all_week)
      ranked = users.sort_by { |u| -weekly_xp(u, range: range) }
      ranked.map.with_index(1) do |user, rank|
        tier_level = user[:league_tier].to_i.nonzero? || 1
        {
          user: user,
          rank: rank,
          weekly_xp: weekly_xp(user, range: range),
          tier: tier_for_user(user),
          movement: league_columns_available? ? user[:league_last_move].to_i : 0,
          projected_movement: projected_movement_for(rank: rank, size: ranked.size, tier_level: tier_level)
        }
      end
    end

    def settle_leagues_if_needed!(reference_time: Time.current)
      return unless league_columns_available?

      assign_rooms_if_needed!

      current_week_start = reference_time.to_date.beginning_of_week
      stale_scope = User.where("league_last_settled_week IS NULL OR league_last_settled_week < ?", current_week_start)
      return unless stale_scope.exists?

      previous_week_start = current_week_start - 1.week
      previous_week_range = previous_week_start.beginning_of_day..(current_week_start.beginning_of_day - 1.second)

      promotions = []
      relegations = []

      (1..TIERS.size).each do |tier|
        grouped_by_room = User.where(league_tier: tier).group_by { |user| user[:league_room].to_i.nonzero? || 1 }

        grouped_by_room.each_value do |tier_room_users|
          ranked = tier_room_users.sort_by { |u| -weekly_xp(u, range: previous_week_range) }
          move_count = promotion_relegation_count_for(ranked.size)
          next if move_count.zero?

          promotions.concat(ranked.first(move_count)) if tier < TIERS.size
          relegations.concat(ranked.last(move_count)) if tier > 1
        end
      end

      ActiveRecord::Base.transaction do
        User.update_all(league_last_settled_week: current_week_start, league_last_move: 0)

        promotions.each do |user|
          user.update_columns(
            league_tier: [user[:league_tier].to_i + 1, TIERS.size].min,
            league_last_move: 1,
            league_last_settled_week: current_week_start
          )
        end

        relegations.each do |user|
          user.update_columns(
            league_tier: [user[:league_tier].to_i - 1, 1].max,
            league_last_move: -1,
            league_last_settled_week: current_week_start
          )
        end

        assign_rooms_if_needed!
      end
    rescue StandardError => e
      Rails.logger.warn("WeeklyLeague settlement failed: #{e.class} #{e.message}")
      nil
    end

    def assign_rooms_if_needed!(tier: nil)
      return unless league_columns_available?

      tiers = tier.present? ? [tier.to_i] : (1..TIERS.size).to_a
      tiers.each { |current_tier| rebalance_rooms_for_tier!(current_tier) }
    end

    def ensure_user_league_slot!(user)
      return unless league_columns_available?

      target_tier = user[:league_tier].to_i.nonzero? || 1
      user.update_columns(league_tier: target_tier) if user[:league_tier].to_i <= 0
      assign_rooms_if_needed!(tier: target_tier)
      user.reload
    end

    def tier_name(level)
      TIERS[[level.to_i - 1, 0].max] || TIERS.first
    end

    def weekly_xp(user, range: Time.current.all_week)
      user.user_quests.where(completed: true, updated_at: range).joins(:quest).sum("quests.xp")
    end

    private

    def promotion_relegation_count_for(size)
      # A tier room must be full before opening movement to another tier.
      return 0 if size < ROOM_CAPACITY

      [(size * PROMOTION_RATE).floor, 1].max
    end

    def projected_movement_for(rank:, size:, tier_level:)
      move_count = promotion_relegation_count_for(size)
      return 0 if move_count.zero?

      if rank <= move_count && tier_level < TIERS.size
        1
      elsif rank > size - move_count && tier_level > 1
        -1
      else
        0
      end
    end

    def tier_for_user(user)
      return tier_name(user[:league_tier]) if league_columns_available?

      TIERS.first
    end

    def league_columns_available?
      @league_columns_available ||= begin
        columns = User.column_names
        columns.include?("league_tier") && columns.include?("league_last_settled_week") && columns.include?("league_last_move") && columns.include?("league_room")
      end
    end

    def rebalance_rooms_for_tier!(tier)
      tier_users = User.where(league_tier: tier).order(id: :asc).to_a
      return if tier_users.empty?

      tier_users.each_with_index do |user, index|
        desired_room = (index / ROOM_CAPACITY) + 1
        next if user[:league_room].to_i == desired_room

        user.update_columns(league_room: desired_room)
      end
    end
  end
end
