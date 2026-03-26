require "rails_helper"

RSpec.describe UserItem, type: :model do
  let(:avatar_url) do
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
  end

  it "prevents duplicate item ownership for the same user" do
    user = User.create!(
      email: "user_item_spec@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current,
      pseudo: "UserItemSpec",
      avatar: avatar_url,
      profile_completed: true
    )
    item = ShopItem.create!(
      name: "Objet Unique",
      description: "Objet de test",
      item_type: "title",
      rarity: "rare",
      price_coins: 100
    )

    described_class.create!(user: user, shop_item: item)
    duplicate = described_class.new(user: user, shop_item: item)

    expect(duplicate).not_to be_valid
  end
end
