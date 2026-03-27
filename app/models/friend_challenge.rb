class FriendChallenge < ApplicationRecord
  belongs_to :challenger, class_name: "User"
  belongs_to :challenged, class_name: "User"
  belongs_to :winner, class_name: "User", optional: true

  validates :status, inclusion: { in: %w[pending active completed cancelled] }
  validates :starts_at, :ends_at, presence: true
  validate :ends_after_start

  scope :active, -> { where(status: "active") }
  scope :pending, -> { where(status: "pending") }

  def includes_user?(user)
    challenger_id == user.id || challenged_id == user.id
  end

  def opponent_for(user)
    challenger_id == user.id ? challenged : challenger
  end

  def xp_gain_for(user)
    challenger_id == user.id ? challenger_xp_gain : challenged_xp_gain
  end

  private

  def ends_after_start
    return if starts_at.blank? || ends_at.blank?
    return if ends_at > starts_at

    errors.add(:ends_at, "must be after starts_at")
  end
end
