class UserDailyContract < ApplicationRecord
  belongs_to :user
  belongs_to :daily_contract

  enum :status, {
    offered: "offered",
    accepted: "accepted",
    completed: "completed"
  }, validate: true

  validates :user_id, uniqueness: { scope: :daily_contract_id }

  scope :offered_today, -> { joins(:daily_contract).where(daily_contracts: { active_on: Time.zone.today }) }

  def accepted?
    status == "accepted"
  end

  def completed?
    status == "completed"
  end

  def claimable?
    completed? && reward_claimed_at.nil?
  end

  def accept!
    with_lock do
      return false unless offered?

      update!(status: "accepted", accepted_at: Time.current)
    end

    true
  end

  def register_progress!(step: 1)
    with_lock do
      return false unless accepted?

      new_progress = progress_count + step
      if new_progress >= daily_contract.target_count
        update!(
          progress_count: daily_contract.target_count,
          status: "completed",
          completed_at: Time.current
        )
      else
        update!(progress_count: new_progress)
      end
    end

    true
  end

  def claim_reward!
    with_lock do
      return false unless claimable?

      transaction do
        user.with_lock do
          user.update!(free_credits: user.free_credits_balance + daily_contract.reward_coins)
        end
        update!(reward_claimed_at: Time.current)
      end
    end

    true
  end

  def self.progress_for_user!(user)
    active = user.user_daily_contracts
      .joins(:daily_contract)
      .where(status: "accepted", daily_contracts: { active_on: Time.zone.today })
      .order(:id)
      .first

    return false unless active

    active.register_progress!
  end
end
