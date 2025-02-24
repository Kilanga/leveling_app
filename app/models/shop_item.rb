class ShopItem < ApplicationRecord
  has_many :user_items
  has_many :users, through: :user_items

  has_one_attached :image # 📌 Utilisation d’Active Storage

  validates :name, :description, presence: true
  validates :price_coins, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :price_euros, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :item_type, presence: true, inclusion: { in: ["title", "boost", "cosmetic", "currency"] }
  validates :rarity, presence: true, inclusion: { in: ["rare", "epic", "legendary"] }

  def rarity_class
    case rarity
    when "rare"
      "text-primary" # Bleu
    when "epic"
      "text-purple" # Violet
    when "legendary"
      "text-warning" # Or
    else
      "text-muted" # Par défaut
    end
  end
end
