class UserWeeklyQuest < ApplicationRecord
  belongs_to :user
  belongs_to :weekly_quest
end
