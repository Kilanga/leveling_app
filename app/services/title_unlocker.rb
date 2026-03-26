class TitleUnlocker
  TITLE_DEFINITIONS = [
    {
      name: "Eclaireur",
      rarity: "common",
      objective: "Completer 3 quetes au total.",
      description: "Tu as fait tes premiers pas d'aventurier.",
      condition: ->(stats) { stats[:completed_quests] >= 3 }
    },
    {
      name: "Regulier",
      rarity: "common",
      objective: "Completer 10 quetes au total.",
      description: "Ta constance commence a se voir.",
      condition: ->(stats) { stats[:completed_quests] >= 10 }
    },
    {
      name: "Polyvalent",
      rarity: "common",
      objective: "Atteindre 500 XP dans 2 categories differentes.",
      description: "Tu progresses sur plusieurs fronts.",
      condition: ->(stats) { stats[:categories_with_500_xp] >= 2 }
    },
    {
      name: "Cadence Hebdo",
      rarity: "common",
      objective: "Completer 3 quetes hebdomadaires en 7 jours.",
      description: "Ton rythme hebdomadaire est solide.",
      condition: ->(stats) { stats[:weekly_completed_7d] >= 3 }
    },
    {
      name: "Stratege Patient",
      rarity: "rare",
      objective: "Atteindre un niveau total de 25.",
      description: "Tu construis ta progression avec discipline.",
      condition: ->(stats) { stats[:total_level] >= 25 }
    },
    {
      name: "Architecte du Progres",
      rarity: "epic",
      objective: "Completer 40 quetes uniques.",
      description: "Tu maitrises un large spectre de missions.",
      condition: ->(stats) { stats[:unique_completed_quests] >= 40 }
    },
    {
      name: "Ascension Totale",
      rarity: "legendary",
      objective: "Atteindre le niveau 10 dans les 5 categories.",
      description: "Tu incarnes l'excellence globale du jeu.",
      condition: ->(stats) { stats[:categories_with_level_10] >= 5 }
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
        categories_with_level_10: user.user_stats.where("level >= 10").distinct.count(:category_id)
      }
    end
  end
end
