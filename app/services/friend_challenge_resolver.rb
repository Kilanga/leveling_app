class FriendChallengeResolver
  class << self
    def resolve_due_challenges!
      FriendChallenge.active.where("ends_at <= ?", Time.current).find_each do |challenge|
        resolve!(challenge)
      end
    end

    def resolve!(challenge)
      challenger_gain = xp_gain(challenge.challenger, challenge.starts_at, challenge.ends_at)
      challenged_gain = xp_gain(challenge.challenged, challenge.starts_at, challenge.ends_at)

      winner = if challenger_gain > challenged_gain
        challenge.challenger
      elsif challenged_gain > challenger_gain
        challenge.challenged
      end

      ActiveRecord::Base.transaction do
        challenge.update!(
          status: "completed",
          winner: winner,
          challenger_xp_gain: challenger_gain,
          challenged_xp_gain: challenged_gain
        )

        if winner
          winner.increment!(:coins, challenge.reward_coins)
          InAppNotification.create!(
            user: winner,
            kind: "challenge_won",
            title: "Defi gagne !",
            body: "Tu remportes #{challenge.reward_coins} coins.",
            cta_path: "/friends"
          )
        end
      end
    end

    private

    def xp_gain(user, starts_at, ends_at)
      user.user_quests.where(completed: true, updated_at: starts_at..ends_at).joins(:quest).sum("quests.xp")
    end
  end
end
