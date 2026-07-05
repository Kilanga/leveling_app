# Passe de saison : 10 paliers débloqués à l'XP saisonnier (user_seasons.xp).
# Piste gratuite pour tous, piste premium débloquée via Stripe.
# Les récompenses se réclament palier par palier (rien n'est perdu :
# un palier atteint reste réclamable jusqu'à la fin de la saison).
class SeasonPass
  PRICE_EUR = 10

  # Paliers : seuils d'XP saisonnier et récompenses des deux pistes.
  # Types de récompenses : fragments, orbs, boost_days, title (exclusif).
  TIERS = [
    { tier: 1,  xp: 300,  free: { fragments: 40 },  premium: { orbs: 60 } },
    { tier: 2,  xp: 700,  free: { orbs: 30 },       premium: { fragments: 120 } },
    { tier: 3,  xp: 1200, free: { fragments: 60 },  premium: { orbs: 90 } },
    { tier: 4,  xp: 1800, free: { orbs: 40 },       premium: { boost_days: 1 } },
    { tier: 5,  xp: 2500, free: { fragments: 80 },  premium: { orbs: 140 } },
    { tier: 6,  xp: 3300, free: { orbs: 50 },       premium: { fragments: 220 } },
    { tier: 7,  xp: 4200, free: { fragments: 100 }, premium: { orbs: 190 } },
    { tier: 8,  xp: 5200, free: { orbs: 70 },       premium: { boost_days: 3 } },
    { tier: 9,  xp: 6300, free: { fragments: 140 }, premium: { orbs: 260 } },
    { tier: 10, xp: 7500, free: { orbs: 100 },      premium: { orbs: 300, title: true } }
  ].freeze

  class << self
    def premium?(user, season)
      UserSeasonPass.exists?(user: user, season: season)
    end

    # Débloque la piste premium (appelé par le webhook/succès Stripe).
    def unlock_premium!(user, season, transaction_id: nil)
      UserSeasonPass.find_or_create_by!(user: user, season: season) do |pass|
        pass.premium_purchased_at = Time.current
        pass.transaction_id = transaction_id
      end
    end

    # État complet du passe pour l'affichage : chaque palier avec
    # unlocked / claimed par piste.
    def state_for(user, season)
      xp = season.user_seasons.find_by(user: user)&.xp.to_i
      premium = premium?(user, season)
      claims = SeasonPassClaim.where(user: user, season: season)
                              .pluck(:tier, :track)
                              .group_by(&:first)
                              .transform_values { |pairs| pairs.map(&:last) }

      tiers = TIERS.map do |definition|
        claimed_tracks = claims.fetch(definition[:tier], [])
        {
          tier: definition[:tier],
          xp: definition[:xp],
          free: definition[:free],
          premium: definition[:premium],
          unlocked: xp >= definition[:xp],
          free_claimed: claimed_tracks.include?("free"),
          premium_claimed: claimed_tracks.include?("premium")
        }
      end

      {
        xp: xp,
        premium: premium,
        tiers: tiers,
        next_tier: tiers.find { |t| !t[:unlocked] }
      }
    end

    # Réclame la récompense d'un palier. Retourne la récompense appliquée
    # (hash) ou nil si non réclamable.
    def claim!(user, season, tier:, track:)
      definition = TIERS.find { |t| t[:tier] == tier.to_i }
      return nil unless definition
      return nil unless SeasonPassClaim::TRACKS.include?(track)
      return nil if track == "premium" && !premium?(user, season)

      xp = season.user_seasons.find_by(user: user)&.xp.to_i
      return nil if xp < definition[:xp]

      reward = definition[track.to_sym]

      ActiveRecord::Base.transaction do
        SeasonPassClaim.create!(user: user, season: season, tier: definition[:tier], track: track)
        apply_reward!(user, season, reward)
      end

      ProductAnalytics.track(
        user: user,
        event_name: "season_pass_claimed",
        metadata: { season_id: season.id, tier: definition[:tier], track: track }
      )

      reward
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
      nil
    end

    def exclusive_title!(season)
      ShopItem.find_or_create_by!(name: "Élu de la Saison #{season.number}", item_type: "title") do |item|
        item.rarity = "legendary"
        item.price_coins = nil
        item.price_euros = nil
        item.description = "Titre exclusif du palier 10 premium du passe de la #{season.name}."
      end
    end

    private

    def apply_reward!(user, season, reward)
      user.add_free_credits!(reward[:fragments]) if reward[:fragments].to_i.positive?
      user.increment!(:coins, reward[:orbs]) if reward[:orbs].to_i.positive?

      if reward[:boost_days].to_i.positive?
        base_time = [ user.boost_expires_at, Time.current ].compact.max
        user.update!(boost_expires_at: base_time + reward[:boost_days].to_i.days)
      end

      user.user_items.find_or_create_by!(shop_item: exclusive_title!(season)) if reward[:title]
    end
  end
end
