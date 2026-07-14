require "rails_helper"

RSpec.describe AbuseGuard do
  let(:avatar_url) do
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
  end

  def create_user(idx)
    User.create!(email: "abuse_#{idx}@example.com", password: "password123", password_confirmation: "password123",
                 confirmed_at: Time.current, pseudo: "Abuse#{idx}", avatar: avatar_url, profile_completed: true)
  end

  def add_completions(user, count, at:)
    count.times { ProductEvent.create!(user: user, event_name: "quest_completed", metadata_json: "{}", created_at: at) }
  end

  it "bloque en burst (>= 10 validations en 60 s)" do
    user = create_user(1)
    add_completions(user, 10, at: 10.seconds.ago)
    expect(described_class.block_reason(user)).to eq(:burst)
  end

  it "laisse passer un rythme normal" do
    user = create_user(2)
    add_completions(user, 3, at: 10.seconds.ago)
    expect(described_class.block_reason(user)).to be_nil
  end

  it "bloque au plafond quotidien (>= 60/jour)" do
    user = create_user(3)
    add_completions(user, 60, at: 90.seconds.ago)
    expect(described_class.block_reason(user)).to eq(:daily_cap)
  end
end
