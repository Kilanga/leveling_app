class SeedDefaultCosmeticItems < ActiveRecord::Migration[8.1]
  def up
    # Profile Frames
    ShopItem.find_or_create_by!(name: "Cadre Standard", item_type: "profile_frame") do |item|
      item.description = "Bordure bleu luminescent autour de ton pseudo au classement."
      item.rarity = "common"
      item.price_coins = nil
      item.price_euros = nil
    end

    ShopItem.find_or_create_by!(name: "Cadre Electrique", item_type: "profile_frame") do |item|
      item.description = "Bordure violette scintillante avec effet de foudre."
      item.rarity = "rare"
      item.price_coins = 300
      item.price_euros = nil
    end

    ShopItem.find_or_create_by!(name: "Cadre Legendaire", item_type: "profile_frame") do |item|
      item.description = "Bordure doree imposante avec particules de feu."
      item.rarity = "epic"
      item.price_coins = 600
      item.price_euros = nil
    end

    # XP Bar Themes
    ShopItem.find_or_create_by!(name: "Theme XP Standard", item_type: "xp_theme") do |item|
      item.description = "Barre XP bleu classique avec progression lineaire."
      item.rarity = "common"
      item.price_coins = nil
      item.price_euros = nil
    end

    ShopItem.find_or_create_by!(name: "Theme XP Samourai", item_type: "xp_theme") do |item|
      item.description = "Barre rouge sang avec dégradé orange pour une vibe guerrière."
      item.rarity = "rare"
      item.price_coins = 200
      item.price_euros = nil
    end

    ShopItem.find_or_create_by!(name: "Theme XP Neon", item_type: "xp_theme") do |item|
      item.description = "Barre vert luminescent cyberpunk avec glow intense."
      item.rarity = "rare"
      item.price_coins = 200
      item.price_euros = nil
    end

    ShopItem.find_or_create_by!(name: "Theme XP Legendaire", item_type: "xp_theme") do |item|
      item.description = "Barre dégradée or-violet avec particules de magie."
      item.rarity = "epic"
      item.price_coins = 400
      item.price_euros = nil
    end

    # Profile Cards
    ShopItem.find_or_create_by!(name: "Carte de Visite Standard", item_type: "profile_card") do |item|
      item.description = "Carte simple noire avec bordure grise."
      item.rarity = "common"
      item.price_coins = nil
      item.price_euros = nil
    end

    ShopItem.find_or_create_by!(name: "Carte de Visite Bleu Nuit", item_type: "profile_card") do |item|
      item.description = "Carte elegante bleu marine avec accent or."
      item.rarity = "rare"
      item.price_coins = 250
      item.price_euros = nil
    end

    ShopItem.find_or_create_by!(name: "Carte de Visite Incendie", item_type: "profile_card") do |item|
      item.description = "Carte avec gradient rouge-orange, texture de feu."
      item.rarity = "rare"
      item.price_coins = 250
      item.price_euros = nil
    end

    ShopItem.find_or_create_by!(name: "Carte de Visite Royale", item_type: "profile_card") do |item|
      item.description = "Carte luxe violet-or avec couronne animée."
      item.rarity = "epic"
      item.price_coins = 500
      item.price_euros = nil
    end
  end

  def down
    ShopItem.where(item_type: ["profile_frame", "xp_theme", "profile_card"]).delete_all
  end
end
