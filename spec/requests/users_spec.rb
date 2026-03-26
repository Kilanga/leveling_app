require "rails_helper"

RSpec.describe "Users", type: :request do
  let(:avatar_url) do
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
  end

  describe "GET /profil" do
    it "returns http success for authenticated user" do
      user = User.create!(
        email: "profile_spec@example.com",
        password: "password123",
        password_confirmation: "password123",
        confirmed_at: Time.current,
        pseudo: "ProfileSpec",
        avatar: avatar_url,
        profile_completed: true
      )

      sign_in user
      get user_profile_path

      expect(response).to have_http_status(:success)
    end
  end
end
