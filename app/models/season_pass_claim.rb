# Palier de passe de saison réclamé par un joueur (piste gratuite ou premium).
class SeasonPassClaim < ApplicationRecord
  TRACKS = %w[free premium].freeze

  belongs_to :user
  belongs_to :season

  validates :tier, presence: true, numericality: { greater_than: 0 }
  validates :track, inclusion: { in: TRACKS }
  validates :tier, uniqueness: { scope: [ :user_id, :season_id, :track ] }
end
