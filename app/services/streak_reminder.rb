# Rappelle aux joueurs dont la streak hebdo est en danger de valider une quête.
# Conçu pour être lancé quotidiennement (Heroku Scheduler) ; n'agit que
# vendredi/samedi/dimanche et une seule fois par joueur et par semaine.
class StreakReminder
  KIND = "streak_reminder".freeze
  DAYS_LEFT_THRESHOLD = 2 # ven(2), sam(1), dim(0) — semaine commençant lundi

  class << self
    def call(today: Date.current)
      days_left = (today.end_of_week - today).to_i
      return 0 if days_left > DAYS_LEFT_THRESHOLD

      week_start = today.beginning_of_week
      sent = 0

      at_risk_users(week_start).find_each do |user|
        next if already_reminded_this_week?(user)

        InAppNotifier.notify!(user: user, kind: KIND, cta_path: "/quests", count: user.weekly_streak_count, days: days_left + 1)
        UserMailer.streak_reminder_email(user).deliver_now rescue Rails.logger.error("StreakReminder mail failed for user #{user.id}: #{$!.message}")
        sent += 1
      end
      sent
    end

    private

    # Streak active mais aucune complétion cette semaine.
    def at_risk_users(week_start)
      User.where("weekly_streak_count >= 1")
          .where("weekly_streak_last_completed_on < ?", week_start)
    end

    def already_reminded_this_week?(user)
      InAppNotification.where(user: user, kind: KIND, created_at: Time.current.all_week).exists?
    end
  end
end
