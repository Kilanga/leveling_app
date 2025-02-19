class User < ApplicationRecord
  # Devise inclusions
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable

  has_many :user_quests, dependent: :destroy
  has_many :quests, through: :user_quests
  has_many :user_stats, dependent: :destroy
  has_many :purchases, dependent: :destroy
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships, source: :friend

  validates :pseudo, presence: true, uniqueness: true, length: { minimum: 3, maximum: 20 }
  validates :email, presence: true, uniqueness: true
  validates :avatar, presence: true, inclusion: { in: [
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp",
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.50_-_A_digital_painting_of_a_female_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._She_wears_a_simple_slightly_x4zdiw.webp"
  ], message: "doit être un avatar valide" }

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
