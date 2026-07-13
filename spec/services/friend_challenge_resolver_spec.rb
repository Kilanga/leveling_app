require "rails_helper"

RSpec.describe FriendChallengeResolver do
  let(:avatar_url) do
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
  end

  def create_user(idx)
    User.create!(email: "fcr_#{idx}@example.com", password: "password123", password_confirmation: "password123",
                 confirmed_at: Time.current, pseudo: "Fcr#{idx}", avatar: avatar_url, profile_completed: true)
  end

  it "désigne le gagnant (plus d'XP sur la fenêtre) et le récompense" do
    challenger = create_user(1)
    challenged = create_user(2)
    category = Category.create!(name: "Discipline")
    quest = Quest.create!(title: "Q", description: "d", xp: 100, difficulty: "E", category: category)

    uq = UserQuest.create!(user: challenger, quest: quest, active: true, completed: true, progress: 0, completed_count: 1)
    uq.update_column(:updated_at, 1.hour.ago)

    challenge = FriendChallenge.create!(challenger: challenger, challenged: challenged, status: "active",
                                        starts_at: 2.hours.ago, ends_at: 1.minute.ago, reward_coins: 80)

    expect { described_class.resolve!(challenge) }.to change { challenger.reload.free_credits }.by(80)

    challenge.reload
    expect(challenge.status).to eq("completed")
    expect(challenge.winner_id).to eq(challenger.id)
  end
end
