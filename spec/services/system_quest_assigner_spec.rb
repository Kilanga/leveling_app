require "rails_helper"

RSpec.describe SystemQuestAssigner do
  let(:avatar_url) do
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
  end

  def create_user(index)
    User.create!(
      email: "assigner_#{index}@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current,
      pseudo: "Assigner#{index}",
      avatar: avatar_url,
      profile_completed: true
    )
  end

  # Un rang E (aucun user_stat -> niveau total 0) rend éligibles les
  # difficultés E et D. On peuple le pool en conséquence.
  def seed_pool!
    %w[Discipline Physique Savoir Social Défi].each_with_index do |name, i|
      category = Category.find_or_create_by!(name: name)
      Quest.create!(title: "#{name} E", description: "d", xp: 120, difficulty: "E", category: category)
      Quest.create!(title: "#{name} D", description: "d", xp: 180, difficulty: "D", category: category)
    end
  end

  it "assigne entre 2 et 3 quêtes du jour (densité V3 réduite)" do
    seed_pool!
    user = create_user(1)

    assignments = described_class.assign_for!(user)

    expect(assignments.size).to be_between(SystemQuestAssigner::MIN_QUESTS, SystemQuestAssigner::MAX_QUESTS)
    expect(SystemQuestAssigner::MIN_QUESTS).to eq(2)
    expect(SystemQuestAssigner::MAX_QUESTS).to eq(3)
  end

  it "n'assigne jamais de quête signature (elles restent aspirationnelles)" do
    seed_pool!
    signature_category = Category.find_by(name: "Discipline")
    signature = Quest.create!(
      title: "Boss E de test",
      description: "d",
      xp: 240,
      difficulty: "E",
      category: signature_category,
      signature: true
    )

    user = create_user(2)
    assignments = described_class.assign_for!(user)

    expect(assignments.map(&:quest_id)).not_to include(signature.id)
  end

  it "est idempotent le même jour" do
    seed_pool!
    user = create_user(3)

    first = described_class.assign_for!(user)
    second = described_class.assign_for!(user)

    expect(second.map(&:id)).to match_array(first.map(&:id))
  end
end
