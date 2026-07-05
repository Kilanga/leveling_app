# Une quête imposée par le Système à un chasseur pour une journée donnée.
class SystemQuestAssignment < ApplicationRecord
  belongs_to :user
  belongs_to :quest

  validates :assigned_on, presence: true
  validates :quest_id, uniqueness: { scope: [ :user_id, :assigned_on ] }

  scope :for_day, ->(date) { where(assigned_on: date) }
  scope :completed, -> { where.not(completed_at: nil) }
  scope :pending, -> { where(completed_at: nil) }

  def completed?
    completed_at.present?
  end
end
