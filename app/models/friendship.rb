class Friendship < ApplicationRecord
  MAX_PENDING_RECEIVED = 20

  belongs_to :user
  belongs_to :friend, class_name: "User"

  validates :status, inclusion: { in: %w[pending accepted rejected] }
  validates :user_id, uniqueness: { scope: :friend_id, message: "Cette amitié existe déjà." }
  validate :cannot_friend_self

  # Scopes pour faciliter les requêtes
  scope :pending, -> { where(status: "pending") }
  scope :accepted, -> { where(status: "accepted") }

  private

  def cannot_friend_self
    errors.add(:friend_id, "ne peut pas être le même utilisateur") if user_id == friend_id
  end
end
