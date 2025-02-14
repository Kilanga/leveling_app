class User < ApplicationRecord
  # Devise inclusions
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable
  
  has_many :user_quests, dependent: :destroy
  has_many :quests, through: :user_quests
  has_many :user_stats, dependent: :destroy
  has_many :purchases, dependent: :destroy

  validates :pseudo, presence: true, uniqueness: true, length: { minimum: 3, maximum: 20 }
  validates :avatar, presence: true, inclusion: { in: %w(avatar1 avatar2), message: "doit être soit 'avatar1' soit 'avatar2'" }

  validates :email, presence: true, uniqueness: true
  def xp_multiplier
    boost_active? ? 2 : 1
  end

  def boost_active?
    boost_expires_at && boost_expires_at > Time.current
  end
  def admin?
    self.admin
  end
end
