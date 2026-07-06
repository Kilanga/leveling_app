require "rails_helper"

RSpec.describe WeeklyStreakTracker do
  let(:avatar_url) do
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
  end

  def build_user(idx, **attrs)
    User.create!({
      email: "streak_#{idx}@example.com", password: "password123", password_confirmation: "password123",
      confirmed_at: Time.current, pseudo: "Streak#{idx}", avatar: avatar_url, profile_completed: true
    }.merge(attrs))
  end

  it "consomme un jeton pour préserver la série après un trou (>= 2 semaines)" do
    user = build_user(1, weekly_streak_count: 5, weekly_streak_last_completed_on: 3.weeks.ago.to_date, streak_freeze_tokens: 1)
    result = described_class.register_completion!(user)
    user.reload
    expect(result).to eq(5)
    expect(user.weekly_streak_count).to eq(5)
    expect(user.streak_freeze_tokens).to eq(0)
  end

  it "réinitialise la série si aucun jeton n'est disponible" do
    user = build_user(2, weekly_streak_count: 5, weekly_streak_last_completed_on: 3.weeks.ago.to_date, streak_freeze_tokens: 0)
    result = described_class.register_completion!(user)
    user.reload
    expect(result).to eq(1)
    expect(user.streak_freeze_tokens).to eq(0)
  end

  it "continue normalement (+1) sans consommer de jeton après une semaine" do
    user = build_user(3, weekly_streak_count: 4, weekly_streak_last_completed_on: 1.week.ago.to_date, streak_freeze_tokens: 1)
    result = described_class.register_completion!(user)
    user.reload
    expect(result).to eq(5)
    expect(user.streak_freeze_tokens).to eq(1)
  end
end
