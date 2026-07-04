class TitleUnlocker
  # Chaque définition exprime ses conditions en seuils structurés
  # (stat => valeur minimale) pour permettre le calcul de progression
  # sur la page Succès. Les libellés vivent dans les fichiers de locale
  # sous achievements.defs.<key>.
  TITLE_DEFINITIONS = [
    { key: "eclaireur",   name: "Eclaireur",             rarity: "common",
      requirements: { completed_quests: 5 } },
    { key: "regulier",    name: "Regulier",              rarity: "common",
      requirements: { completed_quests: 20, weekly_completed_total: 2 } },
    { key: "polyvalent",  name: "Polyvalent",            rarity: "common",
      requirements: { categories_with_500_xp: 3 } },
    { key: "cadence",     name: "Cadence Hebdo",         rarity: "common",
      requirements: { weekly_completed_total: 4, completed_quests: 25 } },
    { key: "stratege",    name: "Stratege Patient",      rarity: "rare",
      requirements: { total_level: 60, completed_quests: 30 } },
    { key: "architecte",  name: "Architecte du Progres", rarity: "epic",
      requirements: { unique_completed_quests: 70, categories_with_1500_xp: 4 } },
    { key: "ascension",   name: "Ascension Totale",      rarity: "legendary",
      requirements: { categories_with_level_20: 5, total_level: 120 } }
  ].freeze

  class << self
    def call(user)
      stats = stats_for(user)

      TITLE_DEFINITIONS.each do |definition|
        next unless met?(definition, stats)

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

        {
          id: item&.id,
          key: definition[:key],
          name: definition[:name],
          rarity: definition[:rarity],
          objective: I18n.t("achievements.defs.#{definition[:key]}.objective"),
          description: I18n.t("achievements.defs.#{definition[:key]}.description"),
          owned: owned,
          unlocked: met?(definition, stats),
          active: item.present? && user.active_title_id == item.id,
          progress: progress_ratio(definition, stats),
          requirements: definition[:requirements].map do |stat, threshold|
            { stat: stat, current: [ stats[stat], threshold ].min, threshold: threshold }
          end
        }
      end
    end

    private

    def met?(definition, stats)
      definition[:requirements].all? { |stat, threshold| stats[stat] >= threshold }
    end

    # Progression globale = moyenne des ratios de chaque exigence (bornés à 1).
    def progress_ratio(definition, stats)
      ratios = definition[:requirements].map do |stat, threshold|
        [ stats[stat].to_f / threshold, 1.0 ].min
      end
      (ratios.sum / ratios.size).round(3)
    end

    def find_or_create_title!(definition)
      ShopItem.find_or_create_by!(name: definition[:name], item_type: "title") do |item|
        item.rarity = definition[:rarity]
        item.price_coins = nil
        item.price_euros = nil
        item.description = I18n.t("achievements.defs.#{definition[:key]}.description", locale: I18n.default_locale)
      end
    end

    def stats_for(user)
      {
        completed_quests: user.user_quests.sum(:completed_count),
        unique_completed_quests: user.user_quests.where("completed_count > 0").distinct.count(:quest_id),
        total_level: user.user_stats.sum(:level),
        weekly_completed_7d: user.user_weekly_quests.where(completed: true).where("updated_at >= ?", 7.days.ago).count,
        weekly_completed_total: user.user_weekly_quests.where(completed: true).count,
        categories_with_500_xp: user.user_stats.where("total_xp >= 500").distinct.count(:category_id),
        categories_with_1500_xp: user.user_stats.where("total_xp >= 1500").distinct.count(:category_id),
        categories_with_level_20: user.user_stats.where("level >= 20").distinct.count(:category_id)
      }
    end
  end
end
