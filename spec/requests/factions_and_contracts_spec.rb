require "rails_helper"

RSpec.describe "Factions and contracts", type: :request do
  include ActiveSupport::Testing::TimeHelpers

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
      coins: 0,
      free_credits: 0
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

    anchor_date = FactionInfluence.current_cycle_anchor_date

    expect {
      patch user_quest_path(user_quest), params: { action_type: "complete" }
    }.to change {
      FactionInfluence.find_by(faction: faction, on_date: anchor_date)&.points.to_i
    }.by(1)
  end

  it "joins a faction via join endpoint" do
    Faction.bootstrap_defaults!
    faction = Faction.first

    sign_in user

    post join_faction_path(faction)

    expect(response).to redirect_to(dashboard_path)
    expect(user.reload.faction_id).to eq(faction.id)
    expect(user.reload.faction_joined_at).to be_present
  end

  it "blocks faction change until weekly reset" do
    travel_to Time.zone.parse("2026-03-30 10:00:00") do
      Faction.bootstrap_defaults!
      source_faction = Faction.find_by!(slug: "aegis")
      target_faction = Faction.find_by!(slug: "ember")

      user.update!(faction: source_faction, faction_joined_at: Time.zone.parse("2026-03-27 13:00:00"))
      sign_in user

      post join_faction_path(target_faction)

      expect(response).to redirect_to(dashboard_path)
      expect(user.reload.faction_id).to eq(source_faction.id)
    end
  end

  it "allows faction change after weekly reset" do
    travel_to Time.zone.parse("2026-04-01 12:01:00") do
      Faction.bootstrap_defaults!
      source_faction = Faction.find_by!(slug: "aegis")
      target_faction = Faction.find_by!(slug: "ember")

      user.update!(faction: source_faction, faction_joined_at: Time.zone.parse("2026-03-25 11:59:00"))
      sign_in user

      post join_faction_path(target_faction)

      expect(response).to redirect_to(dashboard_path)
      expect(user.reload.faction_id).to eq(target_faction.id)
    end
  end

  it "shows guild reset countdown and previous winner participants on dashboard" do
    Faction.bootstrap_defaults!
    winner = Faction.find_by!(slug: "aegis")
    other = Faction.find_by!(slug: "ember")

    cycle_anchor = FactionInfluence.current_cycle_anchor_date
    previous_anchor = cycle_anchor - 7.days

    winner_user = User.create!(
      email: "winner_guild@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current,
      pseudo: "WinnerGuild",
      avatar: avatar_url,
      profile_completed: true
    )

    FactionInfluence.create!(faction: winner, on_date: previous_anchor, points: 12)
    FactionInfluence.create!(faction: other, on_date: previous_anchor, points: 4)
    FactionContribution.create!(faction: winner, user: winner_user, on_date: previous_anchor, points: 7)

    sign_in user

    get dashboard_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Reset dans")
    expect(response.body).to include("Guilde gagnante (semaine precedente): #{winner.name}")
    expect(response.body).to include("WinnerGuild")
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
    }.to change { user.reload.free_credits }.by(55)

    expect(offer.reload.reward_claimed_at).to be_present
  end

  it "does not claim the same daily contract reward twice" do
    contract = DailyContract.create!(
      title: "No double claim",
      description: "Complete 1 quest",
      target_count: 1,
      reward_coins: 55,
      risk_tier: "safe",
      active_on: Time.zone.today
    )

    offer = UserDailyContract.create!(
      user: user,
      daily_contract: contract,
      status: "completed",
      progress_count: 1,
      completed_at: Time.current
    )

    sign_in user

    expect {
      post claim_user_daily_contract_path(offer)
    }.to change { user.reload.free_credits }.by(55)

    expect {
      post claim_user_daily_contract_path(offer)
    }.not_to change { user.reload.free_credits }
  end
end
