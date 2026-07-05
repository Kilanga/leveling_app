require "rails_helper"

RSpec.describe "Welcome", type: :request do
  def avatar_url
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
  end

  def create_hunter(index:, level:, category:)
    user = User.create!(
      email: "welcome_hunter_#{index}@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current,
      pseudo: "Hunter#{index}",
      avatar: avatar_url,
      profile_completed: true
    )
    UserStat.create!(user: user, category: category, level: level, xp: 0, total_xp: 0)
    user
  end

  it "renders the Arise-like landing page for guests" do
    get root_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("Solo Leveling pour ta vraie vie")
    expect(response.body).to include("ascension") # CTA « Commencer l'ascension »
    expect(response.body).to include("Quêtes du jour")
    expect(response.body).to include("Saisons de 6 semaines")
  end

  it "shows the hunter rank ladder E to S" do
    get root_path

    HunterRank::THRESHOLDS.each do |letter, _min|
      expect(response.body).to include("hunter-rank-badge--#{letter.downcase}")
    end
  end

  it "shows top hunters with their rank as social proof" do
    category = Category.create!(name: "Discipline")
    create_hunter(index: 1, level: 30, category: category)  # rang C
    create_hunter(index: 2, level: 140, category: category) # rang S

    get root_path

    expect(response.body).to include("Hunter2")
    expect(response.body).to include("Hunter1")
    # Le rang S (niveau 140) doit apparaître avant le rang C (niveau 30)
    expect(response.body.index("Hunter2")).to be < response.body.index("Hunter1")
  end

  it "renders without a social proof list when there are no players" do
    get root_path

    expect(response).to have_http_status(:success)
    expect(response.body).not_to include("landing-top-hunter__position")
  end

  it "redirects signed-in users to dashboard" do
    user = User.create!(
      email: "welcome_redirect@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current,
      pseudo: "WelcomeUser",
      avatar: avatar_url,
      profile_completed: true
    )

    sign_in user
    get root_path

    expect(response).to redirect_to(dashboard_path)
  end
end
