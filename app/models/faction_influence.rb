class FactionInfluence < ApplicationRecord
  RESET_WDAY = 3
  RESET_HOUR = 12

  belongs_to :faction

  validates :on_date, presence: true
  validates :points, numericality: { greater_than_or_equal_to: 0 }
  validates :faction_id, uniqueness: { scope: :on_date }

  scope :for_date, ->(date) { where(on_date: date) }

  def self.current_cycle_anchor_date(reference_time: Time.current)
    time = reference_time.in_time_zone
    days_since_reset_day = (time.wday - RESET_WDAY) % 7
    this_week_reset = (time - days_since_reset_day.days).change(hour: RESET_HOUR, min: 0, sec: 0)
    cycle_start = time < this_week_reset ? this_week_reset - 7.days : this_week_reset

    cycle_start.to_date
  end

  def self.next_reset_at(reference_time: Time.current)
    time = reference_time.in_time_zone
    days_until_reset_day = (RESET_WDAY - time.wday) % 7
    candidate = (time + days_until_reset_day.days).change(hour: RESET_HOUR, min: 0, sec: 0)

    candidate <= time ? candidate + 7.days : candidate
  end

  def self.add_points!(faction:, points: 1, reference_time: Time.current)
    anchor_date = current_cycle_anchor_date(reference_time: reference_time)
    record = find_or_create_by!(faction: faction, on_date: anchor_date) do |influence|
      influence.points = 0
    end
    record.increment!(:points, points)
  end
end
