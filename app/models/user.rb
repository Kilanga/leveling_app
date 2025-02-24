class User < ApplicationRecord
  # Devise inclusions
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable

  has_many :user_quests, dependent: :destroy
  has_many :quests, through: :user_quests
  has_many :user_stats, dependent: :destroy
  has_many :purchases, dependent: :destroy
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships, source: :friend
  has_many :user_weekly_quests, dependent: :destroy
  has_many :weekly_quests, through: :user_weekly_quests
  has_many :user_badges, dependent: :destroy
  has_many :badges, through: :user_badges
  has_many :user_items
  has_many :shop_items, through: :user_items

  belongs_to :active_title, class_name: "ShopItem", optional: true

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

  # Gestion des titres
  def activate_title(title)
    update(active_title: title)
  end

  def deactivate_title
    update(active_title: nil)
  end

  # Retourne la classe de couleur pour le titre du joueur
  def title_rarity_class
    case active_title&.rarity
    when "rare"
      "primary" # Bleu
    when "epic"
      "purple" # Violet
    when "legendary"
      "warning" # Or
    else
      "secondary" # Par défaut
    end
  end
end
