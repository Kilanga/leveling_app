class User < ApplicationRecord
  GOOGLE_OMNIAUTH_PROVIDERS = if ENV["GOOGLE_CLIENT_ID"].present? && ENV["GOOGLE_CLIENT_SECRET"].present?
    [ :google_oauth2 ]
  else
    []
  end

  # Devise inclusions
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable,
         :omniauthable,
         omniauth_providers: GOOGLE_OMNIAUTH_PROVIDERS

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
  has_many :in_app_notifications, dependent: :destroy
  has_many :experiment_assignments, dependent: :destroy
  has_many :friend_challenges_as_challenger, class_name: "FriendChallenge", foreign_key: :challenger_id, dependent: :destroy
  has_many :friend_challenges_as_challenged, class_name: "FriendChallenge", foreign_key: :challenged_id, dependent: :destroy

  belongs_to :active_title, class_name: "ShopItem", optional: true
  belongs_to :active_avatar_item, class_name: "ShopItem", optional: true

  validates :pseudo, presence: true, uniqueness: true, length: { minimum: 3, maximum: 22 }
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

  def activate_avatar(item)
    return false unless item&.item_type == "cosmetic"
    return false unless user_items.exists?(shop_item_id: item.id)

    update(active_avatar_item: item)
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

  def self.from_google_oauth2(auth)
    new_user = false
    user = find_or_initialize_by(provider: auth.provider, uid: auth.uid)
    new_user = user.new_record?
    email = auth.info.email.to_s.downcase

    user.email = email if user.email.blank?
    user.provider = auth.provider
    user.uid = auth.uid
    user.pseudo = unique_pseudo_for(auth.info.name, email) if user.pseudo.blank?
    user.avatar ||= "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
    user.profile_completed = false if new_user
    user.password = Devise.friendly_token.first(20) if user.encrypted_password.blank?
    user.skip_confirmation! if user.respond_to?(:skip_confirmation!) && !user.confirmed?
    user.save!
    user
  end

  def needs_profile_completion?
    provider == "google_oauth2" && !profile_completed?
  end

  def onboarding_completed?
    onboarding_completed_at.present?
  end

  def onboarding_category_ids
    onboarding_focus.to_s.split(",").map(&:to_i).reject(&:zero?)
  end

  def active_friend_challenges
    FriendChallenge.active.where("challenger_id = :id OR challenged_id = :id", id: id)
  end

  def claim_daily_login_bonus!
    today = Time.zone.today

    with_lock do
      return { claimed: false, streak: daily_login_streak_count.to_i, reward: 0 } if daily_login_last_claimed_on == today

      streak = if daily_login_last_claimed_on == today - 1.day
        daily_login_streak_count.to_i + 1
      else
        1
      end

      # Every 7th day grants a bigger bonus while keeping daily progression rewarding.
      reward = 20 + ([streak, 7].min - 1) * 5
      reward += 40 if (streak % 7).zero?

      update!(
        daily_login_streak_count: streak,
        daily_login_last_claimed_on: today,
        coins: coins.to_i + reward
      )

      { claimed: true, streak: streak, reward: reward }
    end
  end

  def self.unique_pseudo_for(name, email)
    base = name.to_s.parameterize(separator: "_")
    base = email.to_s.split("@").first.to_s.parameterize(separator: "_") if base.blank?
    base = "hunter" if base.blank?
    base = base.first(20)
    base = "hunter" if base.length < 3

    pseudo = base
    suffix = 1
    while User.exists?(pseudo: pseudo)
      suffix += 1
      trimmed = base.first(20 - suffix.to_s.length)
      pseudo = "#{trimmed}#{suffix}"
    end
    pseudo
  end
end
