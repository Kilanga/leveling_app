class UserDailyContract < ApplicationRecord
  belongs_to :user
  belongs_to :daily_contract

  validates :status, presence: true
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
    update!(status: "accepted", accepted_at: Time.current)
  end

  def register_progress!(step: 1)
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

    true
  end

  def claim_reward!
    return false unless claimable?

    transaction do
      user.increment!(:coins, daily_contract.reward_coins)
      update!(reward_claimed_at: Time.current)
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
