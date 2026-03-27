class TitleUnlocker
  TITLE_DEFINITIONS = [
    {
      name: "Eclaireur",
      rarity: "common",
      objective: "Completer 5 quetes au total.",
      description: "Tu as fait tes premiers pas d'aventurier.",
      condition: ->(stats) { stats[:completed_quests] >= 5 }
    },
    {
      name: "Regulier",
      rarity: "common",
      objective: "Completer 20 quetes au total et 2 quetes hebdomadaires en 7 jours.",
      description: "Ta constance commence a se voir.",
      condition: ->(stats) { stats[:completed_quests] >= 20 && stats[:weekly_completed_7d] >= 2 }
    },
    {
      name: "Polyvalent",
      rarity: "common",
      objective: "Atteindre 500 XP dans 3 categories differentes.",
      description: "Tu progresses sur plusieurs fronts.",
      condition: ->(stats) { stats[:categories_with_500_xp] >= 3 }
    },
    {
      name: "Cadence Hebdo",
      rarity: "common",
      objective: "Completer 4 quetes hebdomadaires en 7 jours et 25 quetes au total.",
      description: "Ton rythme hebdomadaire est solide.",
      condition: ->(stats) { stats[:weekly_completed_7d] >= 4 && stats[:completed_quests] >= 25 }
    },
    {
      name: "Stratege Patient",
      rarity: "rare",
      objective: "Atteindre un niveau total de 60 et completer 30 quetes.",
      description: "Tu construis ta progression avec discipline.",
      condition: ->(stats) { stats[:total_level] >= 60 && stats[:completed_quests] >= 30 }
    },
    {
      name: "Architecte du Progres",
      rarity: "epic",
      objective: "Completer 70 quetes uniques et atteindre 1500 XP dans 4 categories.",
      description: "Tu maitrises un large spectre de missions.",
      condition: ->(stats) { stats[:unique_completed_quests] >= 70 && stats[:categories_with_1500_xp] >= 4 }
    },
    {
      name: "Ascension Totale",
      rarity: "legendary",
      objective: "Atteindre le niveau 20 dans les 5 categories et un niveau total de 120.",
      description: "Tu incarnes l'excellence globale du jeu.",
      condition: ->(stats) { stats[:categories_with_level_20] >= 5 && stats[:total_level] >= 120 }
    }
  ].freeze

  class << self
    def call(user)
      stats = stats_for(user)

      TITLE_DEFINITIONS.each do |definition|
        next unless definition[:condition].call(stats)

        item = find_or_create_title!(definition)
        user.user_items.find_or_create_by!(shop_item: item)
      end
    end

    def progress_for(user)
      stats = stats_for(user)
      owned_ids = user.user_items.joins(:shop_item).where(shop_items: { item_type: "title" }).pluck(:shop_item_id).to_set

      TITLE_DEFINITIONS.map do |definition|
        item = ShopItem.find_by(name: definition[:name], item_type: "title")
        owned = item.present? && owned_ids.include?(item.id)
        unlocked = definition[:condition].call(stats)

        {
          id: item&.id,
          name: definition[:name],
          rarity: definition[:rarity],
          objective: definition[:objective],
          description: definition[:description],
          owned: owned,
          unlocked: unlocked,
          active: item.present? && user.active_title_id == item.id
        }
      end
    end

    private

    def find_or_create_title!(definition)
      ShopItem.find_or_create_by!(name: definition[:name], item_type: "title") do |item|
        item.rarity = definition[:rarity]
        item.price_coins = nil
        item.price_euros = nil
        item.description = definition[:description]
      end
    end

    def stats_for(user)
      {
        completed_quests: user.user_quests.sum(:completed_count),
        unique_completed_quests: user.user_quests.where("completed_count > 0").distinct.count(:quest_id),
        total_level: user.user_stats.sum(:level),
        weekly_completed_7d: user.user_weekly_quests.where(completed: true).where("updated_at >= ?", 7.days.ago).count,
        categories_with_500_xp: user.user_stats.where("total_xp >= 500").distinct.count(:category_id),
        categories_with_1500_xp: user.user_stats.where("total_xp >= 1500").distinct.count(:category_id),
        categories_with_level_20: user.user_stats.where("level >= 20").distinct.count(:category_id)
      }
    end
  end
end
