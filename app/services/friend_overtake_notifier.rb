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

        I18n.with_locale(I18n.default_locale) do
          InAppNotification.create!(
            user: friend,
            kind: KIND,
            title: I18n.t("notifications.friend_overtaken.title"),
            body: I18n.t("notifications.friend_overtaken.body", pseudo: user.pseudo),
            cta_path: "/leaderboard"
          )
        end
        notified += 1
      end
      notified
    end

    private

    # Une seule notification par (ami, dépasseur) et par semaine.
    def already_notified_this_week?(friend, overtaker)
      body = I18n.with_locale(I18n.default_locale) do
        I18n.t("notifications.friend_overtaken.body", pseudo: overtaker.pseudo)
      end
      InAppNotification.where(user: friend, kind: KIND, created_at: Time.current.all_week)
                       .exists?(body: body)
    end
  end
end
