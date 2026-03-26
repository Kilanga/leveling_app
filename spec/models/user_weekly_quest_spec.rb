require "rails_helper"

RSpec.describe UserWeeklyQuest, type: :model do
  let(:avatar_url) do
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
  end

  it "belongs to a user and a weekly quest" do
    category = Category.create!(name: "Weekly Spec Category")
    user = User.create!(
      email: "user_weekly_model_spec@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current,
      pseudo: "UserWeeklyModelSpec",
      avatar: avatar_url,
      profile_completed: true
    )
    weekly_quest = WeeklyQuest.create!(
      title: "Weekly model quest",
      description: "Quest de test",
      xp_reward: 300,
      category: category,
      valid_until: 7.days.from_now
    )

    record = described_class.new(user: user, weekly_quest: weekly_quest)
    expect(record).to be_valid
  end
end
