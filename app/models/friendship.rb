class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User"

  validates :user_id, uniqueness: { scope: :friend_id, message: "Cette amitié existe déjà." }

  # Scopes pour faciliter les requêtes
  scope :pending, -> { where(status: "pending") }
  scope :accepted, -> { where(status: "accepted") }
end
