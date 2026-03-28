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
    it "buys a free reward item with free credits" do
      user = create_user(1, free_credits: 300, coins: 120)
      sign_in user

      # Create a test free reward item
      item = ShopItem.create!(
        name: "Test Titre Gratuit",
        item_type: "title",
        description: "Titre debloquable via fragments",
        rarity: "rare",
        price_coins: nil,
        price_euros: nil,
        price_free_credits: 150
      )

      post purchases_path, params: { shop_item_id: item.id }

      expect(user.reload.free_credits).to eq(150)
      expect(user.reload.coins).to eq(120)
      expect(response).to redirect_to(new_purchase_path(tab: "rewards"))
      expect(user.user_items.exists?(shop_item_id: item.id)).to be(true)
    end
    end

    it "does not buy a free reward item when balance is insufficient" do
      user = create_user(2, free_credits: 90, coins: 120)
      item = ShopItem.create!(
        name: "Theme Fragments Test",
        item_type: "xp_theme",
        description: "Objet test",
        rarity: "rare",
        price_coins: nil,
        price_euros: nil,
        price_free_credits: 220
      )

      sign_in user

      post purchases_path, params: { shop_item_id: item.id }

      expect(user.reload.free_credits).to eq(90)
      expect(user.reload.coins).to eq(120)
      expect(user.user_items.exists?(shop_item_id: item.id)).to be(false)
      expect(response).to redirect_to(new_purchase_path)
    end
  end
end
