require "rails_helper"

RSpec.describe QuestRecommender do
  let(:avatar_url) do
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
  end

  def create_user(index, onboarding_focus: "")
    User.create!(
      email: "quest_reco_#{index}@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current,
      pseudo: "QuestReco#{index}",
      avatar: avatar_url,
      profile_completed: true,
      onboarding_focus: onboarding_focus
    )
  end

  it "prioritizes onboarding categories when available" do
    focus_category = Category.create!(name: "Focus")
    other_category = Category.create!(name: "Other")

    user = create_user(1, onboarding_focus: focus_category.id.to_s)
    focused_quest = Quest.create!(title: "Focus Quest", description: "d", xp: 120, category: focus_category)
    Quest.create!(title: "Other Quest", description: "d", xp: 120, category: other_category)

    recommendations = described_class.call(user: user, limit: 2)

    expect(recommendations.first[:quest].id).to eq(focused_quest.id)
    expect(recommendations.first[:reason]).to eq("Dans tes categories prioritaires")
  end

  it "excludes active quests from recommendations" do
    category = Category.create!(name: "No Active")
    user = create_user(2)

    active_quest = Quest.create!(title: "Already Active", description: "d", xp: 110, category: category)
    available_quest = Quest.create!(title: "Available", description: "d", xp: 110, category: category)

    UserQuest.create!(
      user: user,
      quest: active_quest,
      active: true,
      completed: false,
      progress: 0,
      completed_count: 0
    )

    recommendations = described_class.call(user: user, limit: 4)
    ids = recommendations.map { |entry| entry[:quest].id }

    expect(ids).not_to include(active_quest.id)
    expect(ids).to include(available_quest.id)
  end

  it "prefers quests close to the player recent xp rhythm" do
    category = Category.create!(name: "Rhythm")
    user = create_user(3)

    recent_quest_1 = Quest.create!(title: "Recent 1", description: "d", xp: 120, category: category)
    recent_quest_2 = Quest.create!(title: "Recent 2", description: "d", xp: 130, category: category)

    UserQuest.create!(
      user: user,
      quest: recent_quest_1,
      active: true,
      completed: true,
      progress: 0,
      completed_count: 1,
      updated_at: 2.days.ago
    )
    UserQuest.create!(
      user: user,
      quest: recent_quest_2,
      active: true,
      completed: true,
      progress: 0,
      completed_count: 1,
      updated_at: 1.day.ago
    )

    near_quest = Quest.create!(title: "Near XP", description: "d", xp: 125, category: category)
    far_quest = Quest.create!(title: "Far XP", description: "d", xp: 400, category: category)

    recommendations = described_class.call(user: user, limit: 2)

    expect(recommendations.first[:quest].id).to eq(near_quest.id)
    expect(recommendations.map { |entry| entry[:quest].id }).to include(far_quest.id)
  end
end
