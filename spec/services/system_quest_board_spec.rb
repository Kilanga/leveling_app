require "rails_helper"

RSpec.describe SystemQuestBoard do
  let(:avatar_url) do
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
  end

  def create_user(index)
    User.create!(
      email: "board_#{index}@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current,
      pseudo: "Board#{index}",
      avatar: avatar_url,
      profile_completed: true
    )
  end

  it "récompense la journée parfaite au barème V3 (60 fragments, 35% d'XP)" do
    category = Category.create!(name: "Discipline")
    user = create_user(1)

    quest_a = Quest.create!(title: "A", description: "d", xp: 200, difficulty: "D", category: category)
    quest_b = Quest.create!(title: "B", description: "d", xp: 200, difficulty: "D", category: category)

    today = Time.zone.today
    user.system_quest_assignments.create!(quest: quest_a, assigned_on: today)
    user.system_quest_assignments.create!(quest: quest_b, assigned_on: today)

    described_class.register_completion!(user, quest_a)
    result = described_class.register_completion!(user, quest_b)

    expect(result.perfect_day).to be(true)
    expect(result.bonus_fragments).to eq(60)
    expect(SystemQuestBoard::PERFECT_DAY_FRAGMENTS).to eq(60)
    expect(SystemQuestBoard::PERFECT_DAY_XP_RATIO).to eq(0.35)
    # bonus = 35% de (200 + 200) = 140
    expect(result.bonus_xp).to eq(140)
  end

  it "ne déclenche pas la journée parfaite tant qu'une quête reste ouverte" do
    category = Category.create!(name: "Physique")
    user = create_user(2)

    quest_a = Quest.create!(title: "A2", description: "d", xp: 120, difficulty: "E", category: category)
    quest_b = Quest.create!(title: "B2", description: "d", xp: 120, difficulty: "E", category: category)

    today = Time.zone.today
    user.system_quest_assignments.create!(quest: quest_a, assigned_on: today)
    user.system_quest_assignments.create!(quest: quest_b, assigned_on: today)

    result = described_class.register_completion!(user, quest_a)

    expect(result.perfect_day).to be(false)
    expect(result.bonus_fragments).to eq(0)
  end
end
