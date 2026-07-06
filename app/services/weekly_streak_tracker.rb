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
      elsif use_freeze_token!(user, current_week)
        [ user.weekly_streak_count, 1 ].max
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

    # Gel de série ACHETÉ : consomme un jeton pour préserver la série quand le
    # gel gratuit ne s'applique pas (déjà utilisé, ou trou de plus de 2 semaines).
    def use_freeze_token!(user, current_week)
      return false unless user.respond_to?(:streak_freeze_tokens)
      return false unless user.streak_freeze_tokens.to_i.positive?
      return false unless user.weekly_streak_last_completed_on.present?

      gap_weeks = ((current_week - user.weekly_streak_last_completed_on.beginning_of_week).to_i / 7)
      return false unless gap_weeks >= 2

      user.update!(streak_freeze_tokens: user.streak_freeze_tokens - 1)
      begin
        InAppNotifier.notify!(user: user, kind: "streak_freeze_used", count: user.weekly_streak_count)
      rescue StandardError => e
        Rails.logger.warn("[WeeklyStreakTracker] notif gel échouée: #{e.class}")
      end
      true
    end
  end
end
