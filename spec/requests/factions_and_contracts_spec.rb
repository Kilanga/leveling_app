require "rails_helper"

RSpec.describe "Factions and contracts", type: :request do
  let(:avatar_url) do
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
  end

  let(:user) do
    User.create!(
      email: "faction_contracts@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current,
      pseudo: "FactionPlayer",
      avatar: avatar_url,
      profile_completed: true,
      coins: 0
    )
  end

  let(:category) { Category.create!(name: "Faction category") }
  let(:quest) { Quest.create!(title: "Faction quest", description: "q", xp: 100, category: category) }

  it "adds faction influence when a faction member completes a quest" do
    Faction.bootstrap_defaults!
    faction = Faction.first
    user.update!(faction: faction)

    user_quest = UserQuest.create!(user: user, quest: quest, active: true, completed: false, progress: 0, completed_count: 0)

    sign_in user

    expect {
      patch user_quest_path(user_quest), params: { action_type: "complete" }
    }.to change {
      FactionInfluence.find_by(faction: faction, on_date: Time.zone.today)&.points.to_i
    }.by(1)
  end

  it "accepts and claims a daily contract reward after progress" do
    contract = DailyContract.create!(
      title: "Spec contract",
      description: "Complete 1 quest",
      target_count: 1,
      reward_coins: 55,
      risk_tier: "safe",
      active_on: Time.zone.today
    )

    sign_in user

    post accept_daily_contract_path(contract)

    offer = user.user_daily_contracts.find_by!(daily_contract: contract)
    expect(offer.status).to eq("accepted")

    user_quest = UserQuest.create!(user: user, quest: quest, active: true, completed: false, progress: 0, completed_count: 0)
    patch user_quest_path(user_quest), params: { action_type: "complete" }

    expect(offer.reload.status).to eq("completed")

    expect {
      post claim_user_daily_contract_path(offer)
    }.to change { user.reload.coins }.by(55)

    expect(offer.reload.reward_claimed_at).to be_present
  end
end
