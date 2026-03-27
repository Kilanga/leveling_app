class WeeklyStreakTracker
  class << self
    def register_completion!(user)
      current_week = Time.current.to_date.beginning_of_week
      last_week = user.weekly_streak_last_completed_on&.beginning_of_week

      new_streak = if last_week.nil?
        1
      elsif last_week == current_week
        user.weekly_streak_count
      elsif last_week == current_week - 7.days
        user.weekly_streak_count + 1
      elsif can_use_freeze?(user, current_week)
        user.weekly_streak_count + 1
      else
        1
      end

      user.update!(
        weekly_streak_count: new_streak,
        weekly_streak_last_completed_on: Time.current.to_date
      )

      new_streak
    end

    private

    def can_use_freeze?(user, current_week)
      return false if user.weekly_streak_freeze_used_for_week == current_week
      return false unless user.weekly_streak_last_completed_on.present?

      gap_weeks = ((current_week - user.weekly_streak_last_completed_on.beginning_of_week).to_i / 7)
      return false unless gap_weeks == 2

      user.update!(weekly_streak_freeze_used_for_week: current_week)
      true
    end
  end
end
