require "rails_helper"

RSpec.describe "Leaderboard", type: :request do
  let(:avatar_url) do
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
  end

  def create_user_with_stat(index:, category:, xp:)
    user = User.create!(
      email: "leaderboard_#{index}@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current,
      pseudo: "Leader#{index}",
      avatar: avatar_url,
      profile_completed: true
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

  describe "GET /leaderboard" do
    it "limits global ranking to top 10" do
      category = Category.create!(name: "Global")
      current = create_user_with_stat(index: 0, category: category, xp: 1)
      sign_in current

      users = (1..12).map do |i|
        create_user_with_stat(index: i, category: category, xp: 1000 - i)
      end

      get leaderboard_index_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(users.first.pseudo)
      expect(response.body).to include(users[9].pseudo)
      expect(response.body).not_to include(users[10].pseudo)
      expect(response.body).not_to include(users[11].pseudo)
    end

    it "limits category ranking to top 10" do
      category = Category.create!(name: "Focus")
      other_category = Category.create!(name: "Other")
      current = create_user_with_stat(index: 100, category: other_category, xp: 1)
      sign_in current

      focused_users = (1..12).map do |i|
        create_user_with_stat(index: 100 + i, category: category, xp: 1500 - i)
      end

      get leaderboard_index_path, params: { category_id: category.id }

      expect(response).to have_http_status(:success)
      expect(response.body).to include(focused_users.first.pseudo)
      expect(response.body).to include(focused_users[9].pseudo)
      expect(response.body).not_to include(focused_users[10].pseudo)
      expect(response.body).not_to include(focused_users[11].pseudo)
    end
  end
end
