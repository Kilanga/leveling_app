class Purchase < ApplicationRecord
  belongs_to :user

  validates :amount, numericality: { greater_than: 0 }
  validates :item_type, presence: true
  validates :status, presence: true

  after_create :apply_rewards

  private

  def apply_rewards
    return unless status == "completed" && item_type == "coins"

    user.increment!(:coins, amount)
  end
end
