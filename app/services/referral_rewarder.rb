class ReferralRewarder
  INVITEE_REWARD_FREE_CREDITS = 50
  INVITER_REWARD_FREE_CREDITS = 100

  class << self
    def claim_if_eligible!(user)
      return result(:invalid_user) unless user&.persisted?

      user.with_lock do
        return result(:already_rewarded) if user.referral_rewarded_at.present?
        return result(:missing_referrer) unless user.referred_by_id.present?

        referrer = User.find_by(id: user.referred_by_id)
        return result(:missing_referrer) if referrer.blank?
        return result(:self_referral_blocked) if referrer.id == user.id

        ActiveRecord::Base.transaction do
          user.add_free_credits!(INVITEE_REWARD_FREE_CREDITS)
          referrer.add_free_credits!(INVITER_REWARD_FREE_CREDITS)

          base_tx = "referral-#{user.id}-#{referrer.id}"
          user.purchases.create!(
            amount: INVITEE_REWARD_FREE_CREDITS,
            item_type: "referral_invitee_bonus",
            status: "completed",
            transaction_id: "#{base_tx}-invitee"
          )
          referrer.purchases.create!(
            amount: INVITER_REWARD_FREE_CREDITS,
            item_type: "referral_inviter_bonus",
            status: "completed",
            transaction_id: "#{base_tx}-inviter"
          )

          user.update!(referral_rewarded_at: Time.current)

          ProductAnalytics.track(
            user: user,
            event_name: "referral_reward_claimed",
            metadata: { role: "invitee", referrer_id: referrer.id, reward_free_credits: INVITEE_REWARD_FREE_CREDITS }
          )
          ProductAnalytics.track(
            user: referrer,
            event_name: "referral_reward_claimed",
            metadata: { role: "inviter", referred_user_id: user.id, reward_free_credits: INVITER_REWARD_FREE_CREDITS }
          )
        end
      end

      result(:awarded, awarded: true, invitee_reward: INVITEE_REWARD_FREE_CREDITS, inviter_reward: INVITER_REWARD_FREE_CREDITS)
    rescue StandardError => e
      Rails.logger.warn("ReferralRewarder failed: #{e.class} #{e.message}")
      result(:failed)
    end

    private

    def result(reason, awarded: false, invitee_reward: 0, inviter_reward: 0)
      {
        awarded: awarded,
        reason: reason,
        invitee_reward: invitee_reward,
        inviter_reward: inviter_reward
      }
    end
  end
end
