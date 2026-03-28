class FactionContribution < ApplicationRecord
  belongs_to :faction
  belongs_to :user

  validates :on_date, presence: true
  validates :points, numericality: { greater_than_or_equal_to: 0 }
  validates :user_id, uniqueness: { scope: [ :faction_id, :on_date ] }

  def self.add_points!(faction:, user:, reference_time: Time.current, points: 1)
    anchor_date = FactionInfluence.current_cycle_anchor_date(reference_time: reference_time)
    record = find_or_create_by!(faction: faction, user: user, on_date: anchor_date) do |contribution|
      contribution.points = 0
    end
    record.increment!(:points, points)
  end
end
