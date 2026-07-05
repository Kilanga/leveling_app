# Orchestration quotidienne des emails de cycle de vie :
# - bienvenue J+3 et J+7 (fenêtres glissantes de 24h, le run quotidien
#   garantit un seul passage par fenêtre)
# - réactivation J+14 pour les joueurs inactifs (dédupliquée sur 30 jours)
class DripScheduler
  REACTIVATION_KIND = "reactivation".freeze

  class << self
    def call(now: Time.current)
      counts = { day3: 0, day7: 0, reactivation: 0 }

      User.where(created_at: (now - 4.days)..(now - 3.days)).find_each do |user|
        UserMailer.welcome_day3_email(user).deliver_later
        counts[:day3] += 1
      end

      User.where(created_at: (now - 8.days)..(now - 7.days)).find_each do |user|
        UserMailer.welcome_day7_email(user).deliver_later
        counts[:day7] += 1
      end

      inactive_users(now).find_each do |user|
        next if recently_reactivated?(user, now)

        InAppNotifier.notify!(user: user, kind: REACTIVATION_KIND, cta_path: "/quests")
        UserMailer.reactivation_email(user).deliver_later
        counts[:reactivation] += 1
      end

      counts
    end

    private

    # Inscrit depuis plus de 14 jours, aucune quête complétée depuis 14 jours.
    def inactive_users(now)
      active_ids = UserQuest.where(completed: true).where("updated_at > ?", now - 14.days).select(:user_id)
      User.where("created_at < ?", now - 14.days).where.not(id: active_ids)
    end

    def recently_reactivated?(user, now)
      InAppNotification.where(user: user, kind: REACTIVATION_KIND)
                       .where("created_at > ?", now - 30.days)
                       .exists?
    end
  end
end
