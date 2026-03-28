require "rails_helper"

RSpec.describe "Purchases", type: :request do
  let(:avatar_url) do
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
  end

  def create_user(index, free_credits: 0, coins: 0)
    User.create!(
      email: "purchases_spec_#{index}@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current,
      pseudo: "PurchasesSpec#{index}",
      avatar: avatar_url,
      profile_completed: true,
      free_credits: free_credits,
      coins: coins
    )
  end

  describe "POST /purchases" do
    it "buys a free-reward item with fragments when player chooses fragments" do
      user = create_user(1, free_credits: 300, coins: 120)
      sign_in user

      item = ShopItem.create!(
        name: "Theme Fragments Test",
        item_type: "xp_theme",
        description: "Objet test",
        rarity: "rare",
        price_coins: nil,
        price_euros: nil,
        price_free_credits: 150
      )

      post purchases_path, params: { shop_item_id: item.id, currency: "fragments" }

      expect(user.reload.free_credits).to eq(150)
      expect(user.reload.coins).to eq(120)
      expect(response).to redirect_to(new_purchase_path(tab: "rewards"))
      expect(user.user_items.exists?(shop_item_id: item.id)).to be(true)
    end

    it "does not auto-fallback to orbes when player chose fragments" do
      user = create_user(2, free_credits: 90, coins: 150)
      sign_in user

      # 220 fragments required, user has only 90 but enough orbes for fallback.
      # Since player chose fragments, purchase must fail without auto fallback.
      item = ShopItem.create!(
        name: "Cadre Fragments Test",
        item_type: "profile_frame",
        description: "Objet test",
        rarity: "epic",
        price_coins: nil,
        price_euros: nil,
        price_free_credits: 220
      )

      post purchases_path, params: { shop_item_id: item.id, currency: "fragments" }

      expect(user.reload.free_credits).to eq(90)
      expect(user.reload.coins).to eq(150)
      expect(response).to redirect_to(new_purchase_path(tab: "rewards"))
      expect(user.user_items.exists?(shop_item_id: item.id)).to be(false)
      expect(flash[:alert]).to include("pas assez de Fragments")
    end

    it "buys with orbes fallback when player explicitly chooses orbes" do
      user = create_user(3, free_credits: 90, coins: 150)
      sign_in user

      # 220 fragments -> 110 orbes fallback
      item = ShopItem.create!(
        name: "Cadre Orbes Fallback Test",
        item_type: "profile_frame",
        description: "Objet test",
        rarity: "epic",
        price_coins: nil,
        price_euros: nil,
        price_free_credits: 220
      )

      post purchases_path, params: { shop_item_id: item.id, currency: "orbes" }

      expect(user.reload.free_credits).to eq(90)
      expect(user.reload.coins).to eq(40)
      expect(response).to redirect_to(new_purchase_path(tab: "rewards"))
      expect(user.user_items.exists?(shop_item_id: item.id)).to be(true)
    end

    it "does not buy with orbes when player chose orbes and has insufficient orbes" do
      user = create_user(4, free_credits: 500, coins: 100)
      sign_in user

      # User has enough fragments but chose orbes explicitly.
      item = ShopItem.create!(
        name: "Carte Fragments Test",
        item_type: "profile_card",
        description: "Objet test",
        rarity: "epic",
        price_coins: nil,
        price_euros: nil,
        price_free_credits: 260
      )

      post purchases_path, params: { shop_item_id: item.id, currency: "orbes" }

      expect(user.reload.free_credits).to eq(500)
      expect(user.reload.coins).to eq(100)
      expect(response).to redirect_to(new_purchase_path(tab: "rewards"))
      expect(user.user_items.exists?(shop_item_id: item.id)).to be(false)
      expect(flash[:alert]).to include("pas assez d'Orbes")
    end

    it "rejects free-reward purchase when currency choice is missing or invalid" do
      user = create_user(5, free_credits: 500, coins: 500)
      sign_in user

      item = ShopItem.create!(
        name: "Invalid Currency Choice Test",
        item_type: "xp_theme",
        description: "Objet test",
        rarity: "rare",
        price_coins: nil,
        price_euros: nil,
        price_free_credits: 220
      )

      post purchases_path, params: { shop_item_id: item.id }

      expect(user.reload.free_credits).to eq(500)
      expect(user.reload.coins).to eq(500)
      expect(response).to redirect_to(new_purchase_path(tab: "rewards"))
      expect(user.user_items.exists?(shop_item_id: item.id)).to be(false)
      expect(flash[:alert]).to include("Choisis une monnaie valide")
    end

    it "never uses fragments for premium-orbes items" do
      user = create_user(6, free_credits: 5000, coins: 100)
      sign_in user

      item = ShopItem.create!(
        name: "Premium Orbes Only",
        item_type: "profile_frame",
        description: "Premium only",
        rarity: "epic",
        price_coins: 200,
        price_euros: nil,
        price_free_credits: nil
      )

      post purchases_path, params: { shop_item_id: item.id }

      expect(user.reload.free_credits).to eq(5000)
      expect(user.reload.coins).to eq(100)
      expect(response).to redirect_to(new_purchase_path)
      expect(user.user_items.exists?(shop_item_id: item.id)).to be(false)
      expect(flash[:alert]).to include("pas assez d'Orbes")
    end

    it "supports ceil rounding for odd fragment prices when player chooses orbes" do
      user = create_user(7, free_credits: 10, coins: 100)
      sign_in user

      # 181 fragments -> ceil(181/2) = 91 orbes
      item = ShopItem.create!(
        name: "Odd Fragments Test",
        item_type: "xp_theme",
        description: "Objet test",
        rarity: "rare",
        price_coins: nil,
        price_euros: nil,
        price_free_credits: 181
      )

      post purchases_path, params: { shop_item_id: item.id, currency: "orbes" }

      expect(user.reload.free_credits).to eq(10)
      expect(user.reload.coins).to eq(9)
      expect(user.user_items.exists?(shop_item_id: item.id)).to be(true)
    end
  end
end
