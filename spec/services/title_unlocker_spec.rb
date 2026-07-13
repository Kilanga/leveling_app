require "rails_helper"

RSpec.describe TitleUnlocker do
  let(:avatar_url) do
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
  end

  def create_user(idx)
    User.create!(
      email: "titleunlock_#{idx}@example.com", password: "password123", password_confirmation: "password123",
      confirmed_at: Time.current, pseudo: "TitleU#{idx}", avatar: avatar_url, profile_completed: true
    )
  end

  it "débloque le succès Souverain à un niveau total de 130 (rang S)" do
    user = create_user(1)
    category = Category.create!(name: "Discipline")
    UserStat.create!(user: user, category: category, level: 130, xp: 0, total_xp: 0)

    souverain = described_class.progress_for(user).find { |a| a[:key] == "souverain" }
    expect(souverain).to be_present
    expect(souverain[:unlocked]).to be(true)
    expect(souverain[:progress]).to eq(1.0)
  end

  it "n'est pas débloqué en dessous du seuil" do
    user = create_user(2)
    category = Category.create!(name: "Discipline")
    UserStat.create!(user: user, category: category, level: 40, xp: 0, total_xp: 0)

    souverain = described_class.progress_for(user).find { |a| a[:key] == "souverain" }
    expect(souverain[:unlocked]).to be(false)
  end
end
