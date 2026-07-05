# XP cumulé d'un joueur sur une saison (ledger saisonnier).
class UserSeason < ApplicationRecord
  belongs_to :user
  belongs_to :season

  validates :user_id, uniqueness: { scope: :season_id }
  validates :xp, numericality: { greater_than_or_equal_to: 0 }

  scope :ranked, -> { where("xp > 0").order(xp: :desc, updated_at: :asc) }
end
