require "rails_helper"

RSpec.describe UserBadge, type: :model do
  let(:avatar_url) do
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
  end

  it "prevents duplicate badge attribution for the same user" do
    user = User.create!(
      email: "user_badge_spec@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current,
      pseudo: "UserBadgeSpec",
      avatar: avatar_url,
      profile_completed: true
    )
    badge = Badge.create!(name: "Badge Unique", description: "Badge test")

    described_class.create!(user: user, badge: badge)
    duplicate = described_class.new(user: user, badge: badge)

    expect(duplicate).not_to be_valid
  end
end
