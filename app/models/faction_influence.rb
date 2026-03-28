class FactionInfluence < ApplicationRecord
  belongs_to :faction

  validates :on_date, presence: true
  validates :points, numericality: { greater_than_or_equal_to: 0 }
  validates :faction_id, uniqueness: { scope: :on_date }

  scope :for_date, ->(date) { where(on_date: date) }

  def self.add_points!(faction:, on_date:, points: 1)
    record = find_or_create_by!(faction: faction, on_date: on_date) do |influence|
      influence.points = 0
    end
    record.increment!(:points, points)
  end
end
