class UserQuest < ApplicationRecord
  belongs_to :user
  belongs_to :quest

  validates :progress, numericality: { greater_than_or_equal_to: 0 }

  def complete!
    XpAwarder.complete_user_quest!(self)
  end
end
