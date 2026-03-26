require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  let(:avatar_url) do
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
  end

  let(:user) do
    User.create!(
      email: "mailer@example.com",
      password: "password123",
      pseudo: "mailer_user",
      avatar: avatar_url,
      confirmed_at: Time.current
    )
  end

  it "builds welcome email" do
    mail = described_class.welcome_email(user)

    expect(mail.to).to include(user.email)
    expect(mail.subject).to eq("Bienvenue sur Leveling App !")
  end

  it "builds purchase confirmation email" do
    mail = described_class.purchase_confirmation(user: user, summary: "Pack coins: +100", amount_eur: 5)

    expect(mail.to).to include(user.email)
    expect(mail.subject).to eq("Confirmation d'achat - Leveling")
    expect(mail.body.encoded).to include("Pack coins: +100")
  end
end
