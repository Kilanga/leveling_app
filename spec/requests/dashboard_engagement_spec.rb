require "rails_helper"

RSpec.describe "Dashboard engagement", type: :request do
  let(:avatar_url) do
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
  end

  let(:user) do
    User.create!(
      email: "dashboard_engagement@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current,
      pseudo: "DashEngage",
      avatar: avatar_url,
      profile_completed: true,
      coins: 10
    )
  end

  describe "GET /dashboard" do
    it "claims daily login reward only once per day" do
      sign_in user

      expect {
        get dashboard_path
      }.to change { user.reload.coins }.by(20)

      expect(user.daily_login_streak_count).to eq(1)
      expect(user.daily_login_last_claimed_on).to eq(Time.zone.today)

      expect {
        get dashboard_path
      }.not_to change { user.reload.coins }
    end
  end

  describe "POST /dashboard/claim_daily_chest" do
    it "claims chest when daily target is met" do
      category = Category.create!(name: "Sport")
      quest = Quest.create!(title: "Run", description: "Run quest", xp: 100, category: category)
      second_quest = Quest.create!(title: "Read", description: "Read quest", xp: 120, category: category)
      UserQuest.create!(user: user, quest: quest, completed: true, active: true, progress: 0, completed_count: 1, updated_at: Time.current)
      UserQuest.create!(user: user, quest: second_quest, completed: true, active: true, progress: 0, completed_count: 1, updated_at: Time.current)

      sign_in user

      expect {
        post claim_daily_chest_path
      }.to change { user.reload.coins }.by(35)

      expect(response).to redirect_to(dashboard_path)
      expect(user.purchases.where(item_type: "daily_chest").count).to eq(1)

      expect {
        post claim_daily_chest_path
      }.not_to change { user.reload.coins }
    end

    it "does not claim chest when daily target is not met" do
      category = Category.create!(name: "Code")
      quest = Quest.create!(title: "Ship", description: "Ship quest", xp: 90, category: category)
      UserQuest.create!(user: user, quest: quest, completed: true, active: true, progress: 0, completed_count: 1, updated_at: Time.current)

      sign_in user

      expect {
        post claim_daily_chest_path
      }.not_to change { user.reload.coins }

      expect(response).to redirect_to(dashboard_path)
      expect(user.purchases.where(item_type: "daily_chest")).to be_empty
    end
  end
end
