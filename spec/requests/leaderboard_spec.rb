require "rails_helper"

RSpec.describe "Leaderboard", type: :request do
  let(:avatar_url) do
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
  end

  def create_user_with_stat(index:, category:, xp:, league_tier: 1, league_room: 1)
    user = User.create!(
      email: "leaderboard_#{index}@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current,
      pseudo: "Leader#{index}",
      avatar: avatar_url,
      profile_completed: true,
      league_tier: league_tier,
      league_room: league_room,
      league_last_settled_week: Time.zone.today.beginning_of_week
    )

    UserStat.create!(
      user: user,
      category: category,
      level: 1,
      xp: 0,
      total_xp: xp
    )

    user
  end

  def add_weekly_xp_for(user, category:, xp:)
    quest = Quest.create!(title: "Quest #{user.id}-#{xp}", description: "Spec quest", xp: xp, category: category)
    UserQuest.create!(user: user, quest: quest, completed: true, active: true, progress: 0, completed_count: 1, updated_at: Time.current)
  end

  describe "GET /leaderboard" do
    it "shows complete standings for current league cohort" do
      category = Category.create!(name: "Global")
      current = create_user_with_stat(index: 0, category: category, xp: 1, league_tier: 1, league_room: 1)
      sign_in current
      add_weekly_xp_for(current, category: category, xp: 1)

      users = (1..12).map do |i|
        user = create_user_with_stat(index: i, category: category, xp: 1000 - i, league_tier: 1, league_room: 1)
        add_weekly_xp_for(user, category: category, xp: 1000 - i)
        user
      end

      get leaderboard_index_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(users.first.pseudo)
      expect(response.body).to include(users[9].pseudo)
      expect(response.body).to include(users[10].pseudo)
      expect(response.body).to include(users[11].pseudo)
      expect(response.body).to include(current.pseudo)
      expect(response.body).not_to include("room")
    end

    it "renders hold-only indicators for partial cohorts and no filter form" do
      category = Category.create!(name: "Focus")
      current = create_user_with_stat(index: 100, category: category, xp: 1, league_tier: 2, league_room: 1)
      sign_in current
      add_weekly_xp_for(current, category: category, xp: 1)

      focused_users = (1..12).map do |i|
        user = create_user_with_stat(index: 100 + i, category: category, xp: 1500 - i, league_tier: 2, league_room: 1)
        add_weekly_xp_for(user, category: category, xp: 1500 - i)
        user
      end

      get leaderboard_index_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(focused_users.first.pseudo)
      expect(response.body).to include(focused_users[9].pseudo)
      expect(response.body).to include(focused_users[10].pseudo)
      expect(response.body).to include(focused_users[11].pseudo)
      expect(response.body).to include(current.pseudo)
      expect(response.body).to include("•")
      expect(response.body).not_to include("▲")
      expect(response.body).not_to include("▼")
      expect(response.body).not_to include("Filtrer")
      expect(response.body).not_to include("room")
    end
  end
end
