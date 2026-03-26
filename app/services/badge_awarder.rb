class BadgeAwarder
  class << self
    def call(user)
      award_progression_badges(user)
      award_category_badges(user)
      award_weekly_badge(user)
      award_legend_badge(user)
    end

    private

    def award_progression_badges(user)
      total_quests_completed = user.user_quests.sum(:completed_count)

      award_if_qualified(user, "Débutant", total_quests_completed >= 10)
      award_if_qualified(user, "Aventurier", total_quests_completed >= 50)
      award_if_qualified(user, "Expert", total_quests_completed >= 100)
      award_if_qualified(user, "Maître", total_quests_completed >= 500)
      award_if_qualified(user, "Conquérant", total_quests_completed >= 1000)
    end

    def award_category_badges(user)
      user.user_stats.includes(:category).find_each do |stat|
        next unless stat.total_xp.to_i >= 5000

        case stat.category.name
        when "Discipline"
          award_if_qualified(user, "Maître de la Discipline", true)
        when "Physique"
          award_if_qualified(user, "Athlète Élite", true)
        when "Savoir"
          award_if_qualified(user, "Erudit Suprême", true)
        when "Social"
          award_if_qualified(user, "Charisme Légendaire", true)
        when "Défi"
          award_if_qualified(user, "Maître des Défis", true)
        end
      end
    end

    def award_weekly_badge(user)
      recent_weekly = user.user_weekly_quests.where(completed: true)
                        .where("updated_at >= ?", 7.days.ago)
                        .count

      award_if_qualified(user, "Champion Hebdomadaire", recent_weekly >= 5)
    end

    def award_legend_badge(user)
      all_quests_count = Quest.count
      return if all_quests_count.zero?

      completed_unique_quests = user.user_quests.where("completed_count > 0").distinct.count(:quest_id)
      award_if_qualified(user, "Légende", completed_unique_quests >= all_quests_count)
    end

    def award_if_qualified(user, badge_name, qualified)
      return unless qualified

      badge = Badge.find_by(name: badge_name)
      return if badge.nil? || user.user_badges.exists?(badge_id: badge.id)

      user.user_badges.create!(badge: badge, awarded_at: Time.current)
    end
  end
end
