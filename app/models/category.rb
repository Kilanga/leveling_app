class Category < ApplicationRecord
  has_many :quests, dependent: :destroy
  has_many :user_stats, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
