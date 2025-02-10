class Category < ApplicationRecord
  has_many :quests
  has_many :user_stats
end
