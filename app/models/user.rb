class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable

  has_many :user_quests
  has_many :quests, through: :user_quests
  has_many :user_stats
  has_many :purchases
end
