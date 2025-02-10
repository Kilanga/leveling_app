class Quest < ApplicationRecord
  belongs_to :category
  has_many :user_quests
  has_many :users, through: :user_quests

  validates :title, :description, :xp, :category, presence: true
end
