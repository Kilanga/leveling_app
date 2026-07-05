# Déblocage de la piste premium du passe pour une saison donnée.
class UserSeasonPass < ApplicationRecord
  belongs_to :user
  belongs_to :season

  validates :user_id, uniqueness: { scope: :season_id }
  validates :premium_purchased_at, presence: true
end
