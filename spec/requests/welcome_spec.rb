require "rails_helper"

RSpec.describe "Welcome", type: :request do
  it "renders the public landing page for guests" do
    get root_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("Transforme ta progression en jeu competitif")
    expect(response.body).to include("Commencer maintenant")
  end

  it "redirects signed-in users to dashboard" do
    user = User.create!(
      email: "welcome_redirect@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current,
      pseudo: "WelcomeUser",
      avatar: "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp",
      profile_completed: true
    )

    sign_in user
    get root_path

    expect(response).to redirect_to(dashboard_path)
  end
end
