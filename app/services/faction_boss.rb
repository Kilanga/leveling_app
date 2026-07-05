# Boss hebdomadaire de faction : objectif collectif de points d'influence
# sur le cycle courant. Quand la faction atteint la cible, tous ses membres
# reçoivent des Fragments (une seule fois par cycle).
class FactionBoss
  TARGET_POINTS = 25
  REWARD_FRAGMENTS = 100

  class << self
    def check!(faction, reference_time: Time.current)
      anchor = FactionInfluence.current_cycle_anchor_date(reference_time: reference_time)
      influence = FactionInfluence.for_date(anchor).find_by(faction: faction)
      return false if influence.nil?
      return false if influence.points < TARGET_POINTS
      return false if influence.boss_rewarded_at.present?

      # Verrou optimiste : seul le premier passage récompense
      updated = FactionInfluence.where(id: influence.id, boss_rewarded_at: nil)
                                .update_all(boss_rewarded_at: Time.current)
      return false if updated.zero?

      User.where(faction: faction).find_each do |member|
        member.add_free_credits!(REWARD_FRAGMENTS)
        InAppNotifier.notify!(
          user: member,
          kind: "faction_boss_defeated",
          cta_path: "/",
          faction: faction.name,
          count: REWARD_FRAGMENTS
        )
      end
      true
    end

    def progress_for(faction, reference_time: Time.current)
      anchor = FactionInfluence.current_cycle_anchor_date(reference_time: reference_time)
      influence = FactionInfluence.for_date(anchor).find_by(faction: faction)
      points = influence&.points.to_i
      {
        points: points,
        target: TARGET_POINTS,
        ratio: [ points.to_f / TARGET_POINTS, 1.0 ].min,
        defeated: influence&.boss_rewarded_at.present?
      }
    end
  end
end
