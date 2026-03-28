class DailyContract < ApplicationRecord
  has_many :user_daily_contracts, dependent: :destroy

  validates :title, :description, :risk_tier, :active_on, presence: true
  validates :target_count, :reward_coins, numericality: { greater_than: 0 }

  scope :for_today, -> { where(active_on: Time.zone.today).order(:id) }
end
