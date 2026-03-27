require "rails_helper"

RSpec.describe "Friends", type: :request do
  let(:avatar_url) do
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
  end

  def create_user(index)
    User.create!(
      email: "friends_spec_#{index}@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current,
      pseudo: "FriendSpec#{index}",
      avatar: avatar_url,
      profile_completed: true
    )
  end

  describe "GET /friends" do
    it "redirects unauthenticated users to sign in" do
      get friends_path

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "shows referral block in friends tab for signed-in users" do
      user = create_user(1)
      sign_in user

      get friends_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Parrainage")
      expect(response.body).to include("invite")
    end

    it "does not show referral block on dashboard" do
      user = create_user(2)
      sign_in user

      get dashboard_path

      expect(response).to have_http_status(:success)
      expect(response.body).not_to include("Parrainage")
    end
  end

  describe "POST /friends" do
    it "redirects unauthenticated users to sign in" do
      post friends_path, params: { friend_id: 1 }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
