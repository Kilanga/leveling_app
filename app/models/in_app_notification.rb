class InAppNotification < ApplicationRecord
  belongs_to :user

  validates :kind, :title, presence: true

  scope :unread, -> { where(read_at: nil) }

  def mark_as_read!
    update!(read_at: Time.current)
  end
end
