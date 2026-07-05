# Cycle de vie des saisons (6 semaines) : création, XP saisonnier,
# classement et clôture avec récompenses exclusives.
#
# Principe roadmap V2 : seul le classement saisonnier est remis à zéro
# (nouvelle saison = nouveau ledger). XP, rangs et succès sont permanents.
class SeasonManager
  SEASON_LENGTH = 6.weeks
  TOP_TITLE_COUNT = 3          # titre unique pour le top 3
  BADGE_TOP_RATIO = 0.10       # badge exclusif pour le top 10% (au moins le top 3)

  # Noms thématiques cyclés, ton Solo Leveling.
  THEMES = [
    "L'Éveil",
    "La Traque",
    "Le Donjon Rouge",
    "L'Ascension",
    "Le Territoire des Ombres",
    "La Porte de Rang S"
  ].freeze

  class << self
    # Saison couvrant la date (créée à la volée si nécessaire).
    def current!(date = Time.zone.today)
      Season.covering(date).first || create_covering!(date)
    end

    # Crédite l'XP saisonnier. Appelé par XpAwarder à chaque gain d'XP.
    # Sans effet tant que la migration des saisons n'est pas passée.
    def add_xp!(user, amount, date: Time.zone.today)
      return unless amount.to_i.positive?
      return unless tables_ready?

      season = current!(date)
      entry = season.user_seasons.find_or_create_by!(user: user)
      entry.increment!(:xp, amount.to_i)
    rescue ActiveRecord::RecordNotUnique
      season.user_seasons.find_by!(user: user).increment!(:xp, amount.to_i)
    end

    def leaderboard(season, limit: 20)
      season.user_seasons.ranked.includes(user: [ :active_title, :active_profile_frame ]).limit(limit)
    end

    def rank_for(user, season)
      entry = season.user_seasons.find_by(user: user)
      return nil unless entry && entry.xp.positive?

      season.user_seasons.where("xp > ?", entry.xp).count + 1
    end

    # Job récurrent : clôture les saisons terminées (badge exclusif top 10%,
    # titre unique top 3) puis garantit qu'une saison courante existe.
    def close_finished_seasons!(date = Time.zone.today)
      return unless tables_ready?

      Season.finished_unclosed(date).order(:number).each do |season|
        close!(season)
      end

      current!(date)
    end

    def close!(season)
      return if season.closed?

      ranked = season.user_seasons.ranked.includes(:user).to_a
      badge_count = [ (ranked.size * BADGE_TOP_RATIO).ceil, TOP_TITLE_COUNT ].max

      Season.transaction do
        badge = season_badge!(season)
        ranked.first(badge_count).each do |entry|
          entry.user.user_badges.find_or_create_by!(badge: badge) do |user_badge|
            user_badge.awarded_at = Time.current
          end
        end

        title = season_title!(season)
        ranked.first(TOP_TITLE_COUNT).each do |entry|
          entry.user.user_items.find_or_create_by!(shop_item: title)
        end

        season.update!(closed_at: Time.current)
      end

      notify_rewards(season, ranked, badge_count)
      season
    end

    def theme_for(number)
      THEMES[(number - 1) % THEMES.size]
    end

    # Sûr à appeler avant que la migration des saisons ne soit passée.
    def ready?
      tables_ready?
    end

    private

    def create_covering!(date)
      last = Season.order(:number).last

      if last
        starts_on = last.ends_on + 1.day
        number = last.number
      else
        starts_on = date.beginning_of_week
        number = 0
      end

      # Avance jusqu'à couvrir la date (rattrape les trous d'activité).
      loop do
        number += 1
        ends_on = starts_on + SEASON_LENGTH - 1.day
        if date <= ends_on
          return Season.create!(
            number: number,
            name: "Saison #{number} — #{theme_for(number)}",
            starts_on: starts_on,
            ends_on: ends_on
          )
        end
        starts_on = ends_on + 1.day
      end
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
      Season.covering(date).first or raise
    end

    def season_badge!(season)
      badge = Badge.find_or_create_by!(name: "Élite — #{season.name}") do |record|
        record.description = "A terminé dans le top 10% de la #{season.name}."
        record.rarity = "epic"
        record.is_free = true
      end
      badge
    end

    def season_title!(season)
      ShopItem.find_or_create_by!(name: "Souverain de la Saison #{season.number}", item_type: "title") do |item|
        item.rarity = "legendary"
        item.price_coins = nil
        item.price_euros = nil
        item.description = "Titre unique du top 3 de la #{season.name}."
      end
    end

    def notify_rewards(season, ranked, badge_count)
      ranked.first(badge_count).each_with_index do |entry, index|
        kind = index < TOP_TITLE_COUNT ? "season_top3" : "season_top10"
        InAppNotifier.notify!(
          user: entry.user,
          kind: kind,
          cta_path: "/leaderboard",
          season: season.name,
          rank: index + 1
        )
      rescue StandardError => e
        Rails.logger.warn("[SeasonManager] notification user=#{entry.user_id} : #{e.class} #{e.message}")
      end
    end

    def tables_ready?
      return @tables_ready if defined?(@tables_ready) && @tables_ready

      @tables_ready = Season.table_exists? && UserSeason.table_exists?
    rescue StandardError
      false
    end
  end
end
