class WeeklyQuest < ApplicationRecord
  belongs_to :category
  has_many :user_weekly_quests
has_many :users, through: :user_weekly_quests
end
