# Notifie les amis qu'un joueur vient de dépasser au classement XP hebdo.
# Appelé après un gain d'XP (complétion de quête).
class FriendOvertakeNotifier
  KIND = "friend_overtaken".freeze

  class << self
    def call(user, xp_before:)
      xp_after = WeeklyLeague.weekly_xp(user)
      return 0 if xp_after <= xp_before

      notified = 0
      user.accepted_friends.find_each do |friend|
        friend_xp = WeeklyLeague.weekly_xp(friend)
        next unless friend_xp < xp_after && friend_xp >= xp_before
        next if already_notified_this_week?(friend, user)

        InAppNotifier.notify!(user: friend, kind: KIND, cta_path: "/leaderboard", pseudo: user.pseudo)
        notified += 1
      end
      notified
    end

    private

    # Une seule notification par (ami, dépasseur) et par semaine.
    # Le corps est traduit dans la langue du destinataire, on matche donc
    # sur le pseudo du dépasseur plutôt que sur le texte exact.
    def already_notified_this_week?(friend, overtaker)
      pattern = "%#{ActiveRecord::Base.sanitize_sql_like(overtaker.pseudo)}%"
      InAppNotification.where(user: friend, kind: KIND, created_at: Time.current.all_week)
                       .where("body LIKE ?", pattern)
                       .exists?
    end
  end
end
