require "rails_helper"

RSpec.describe Friendship, type: :model do
  let(:avatar_url) do
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
  end

  let(:user) do
    User.create!(
      email: "user@example.com",
      password: "password123",
      pseudo: "user_one",
      avatar: avatar_url,
      confirmed_at: Time.current
    )
  end

  let(:friend) do
    User.create!(
      email: "friend@example.com",
      password: "password123",
      pseudo: "user_two",
      avatar: avatar_url,
      confirmed_at: Time.current
    )
  end

  it "is valid with a supported status" do
    friendship = described_class.new(user: user, friend: friend, status: "pending")

    expect(friendship).to be_valid
  end

  it "rejects unsupported statuses" do
    friendship = described_class.new(user: user, friend: friend, status: "unknown")

    expect(friendship).not_to be_valid
    expect(friendship.errors[:status]).to be_present
  end

  it "does not allow friending yourself" do
    friendship = described_class.new(user: user, friend: user, status: "pending")

    expect(friendship).not_to be_valid
    expect(friendship.errors[:friend_id]).to be_present
  end
end
