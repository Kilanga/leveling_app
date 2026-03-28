class UserQuest < ApplicationRecord
  DAILY_RESET_HOUR = 22

  belongs_to :user
  belongs_to :quest

  validates :progress, numericality: { greater_than_or_equal_to: 0 }

  def self.current_daily_reset_window_start(reference_time: Time.current)
    current_time = reference_time.in_time_zone
    window_start = current_time.change(hour: DAILY_RESET_HOUR, min: 0, sec: 0)
    current_time < window_start ? window_start - 1.day : window_start
  end

  def locked_until_daily_reset?(reference_time: Time.current)
    return false unless completed?
    return false unless updated_at.present?

    updated_at >= self.class.current_daily_reset_window_start(reference_time: reference_time)
  end

  def complete!
    XpAwarder.complete_user_quest!(self)
  end
end
