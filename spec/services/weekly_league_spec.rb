require "rails_helper"

RSpec.describe WeeklyLeague do
  let(:avatar_url) do
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
  end

  def create_user(index:, tier:)
    User.create!(
      email: "league_settle_#{index}@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current,
      pseudo: "LeagueSettle#{index}",
      avatar: avatar_url,
      profile_completed: true,
      league_tier: tier,
      league_last_settled_week: 2.weeks.ago.to_date.beginning_of_week
    )
  end

  def add_previous_week_xp(user, xp, category)
    quest = Quest.create!(title: "PrevWeek #{user.id}-#{xp}", description: "Spec", xp: xp, category: category)
    UserQuest.create!(
      user: user,
      quest: quest,
      completed: true,
      active: true,
      progress: 0,
      completed_count: 1,
      updated_at: Time.zone.today.beginning_of_week - 2.days
    )
  end

  it "promotes top performers and relegates bottom performers each week" do
    category = Category.create!(name: "League settle")

    tier_two_users = (1..10).map { |i| create_user(index: i, tier: 2) }
    tier_two_users.each_with_index do |user, idx|
      add_previous_week_xp(user, 1000 - idx, category)
    end

    WeeklyLeague.settle_leagues_if_needed!(reference_time: Time.zone.now)

    expect(tier_two_users[0].reload.league_tier).to eq(3)
    expect(tier_two_users[1].reload.league_tier).to eq(3)
    expect(tier_two_users[-1].reload.league_tier).to eq(1)
    expect(tier_two_users[-2].reload.league_tier).to eq(1)
  end

  it "rebalances rooms with a capacity of 50 players per league tier" do
    category = Category.create!(name: "League rooms")

    users = (1..120).map { |i| create_user(index: 1000 + i, tier: 1) }
    users.each_with_index { |user, idx| add_previous_week_xp(user, 1000 - idx, category) }

    WeeklyLeague.assign_rooms_if_needed!(tier: 1)

    counts = User.where(league_tier: 1).group(:league_room).count
    expect(counts[1]).to eq(50)
    expect(counts[2]).to eq(50)
    expect(counts[3]).to eq(20)
  end

  it "projects up and down movements even in a small cohort" do
    category = Category.create!(name: "Small cohort")
    users = (1..4).map { |i| create_user(index: 2000 + i, tier: 2) }
    users.each_with_index { |user, idx| add_previous_week_xp(user, 400 - idx, category) }

    standings = WeeklyLeague.standings(User.where(id: users.map(&:id)).to_a, range: Time.current.all_week)

    expect(standings.first[:projected_movement]).to eq(1)
    expect(standings.last[:projected_movement]).to eq(-1)
  end

  it "never projects impossible moves at tier boundaries" do
    category = Category.create!(name: "Boundary projections")

    bronze_users = (1..3).map { |i| create_user(index: 3000 + i, tier: 1) }
    diamond_users = (1..3).map { |i| create_user(index: 4000 + i, tier: 5) }

    bronze_users.each_with_index { |user, idx| add_previous_week_xp(user, 300 - idx, category) }
    diamond_users.each_with_index { |user, idx| add_previous_week_xp(user, 300 - idx, category) }

    bronze_standings = WeeklyLeague.standings(User.where(id: bronze_users.map(&:id)).to_a, range: Time.current.all_week)
    diamond_standings = WeeklyLeague.standings(User.where(id: diamond_users.map(&:id)).to_a, range: Time.current.all_week)

    expect(bronze_standings.map { |e| e[:projected_movement] }).not_to include(-1)
    expect(diamond_standings.map { |e| e[:projected_movement] }).not_to include(1)
  end

  it "never settles outside league bounds" do
    category = Category.create!(name: "Boundary settlement")

    bronze_users = (1..3).map { |i| create_user(index: 5000 + i, tier: 1) }
    diamond_users = (1..3).map { |i| create_user(index: 6000 + i, tier: 5) }

    bronze_users.each_with_index { |user, idx| add_previous_week_xp(user, 500 - idx, category) }
    diamond_users.each_with_index { |user, idx| add_previous_week_xp(user, 500 - idx, category) }

    WeeklyLeague.settle_leagues_if_needed!(reference_time: Time.zone.now)

    expect(bronze_users.map { |u| u.reload.league_tier }.min).to be >= 1
    expect(diamond_users.map { |u| u.reload.league_tier }.max).to be <= 5
  end
end
