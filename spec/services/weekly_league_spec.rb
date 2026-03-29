require "rails_helper"

RSpec.describe WeeklyLeague do
  let(:settlement_reference_time) { Time.zone.parse("2026-03-29 20:00:00") }

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
      league_last_settled_week: (settlement_reference_time.to_date - 14.days).beginning_of_week
    )
  end

  def add_previous_week_xp(user, xp, category, completed_at: settlement_reference_time - 2.days)
    quest = Quest.create!(title: "PrevWeek #{user.id}-#{xp}", description: "Spec", xp: xp, category: category)
    UserQuest.create!(
      user: user,
      quest: quest,
      completed: true,
      active: true,
      progress: 0,
      completed_count: 1,
      updated_at: completed_at
    )
  end

  it "promotes top performers and relegates bottom performers each week for full rooms" do
    category = Category.create!(name: "League settle")

    tier_two_users = (1..50).map { |i| create_user(index: i, tier: 2) }
    tier_two_users.each_with_index do |user, idx|
      add_previous_week_xp(user, 1000 - idx, category)
    end

    WeeklyLeague.settle_leagues_if_needed!(reference_time: settlement_reference_time)

    expect(tier_two_users[0].reload.league_tier).to eq(3)
    expect(tier_two_users[1].reload.league_tier).to eq(3)
    expect(tier_two_users[-1].reload.league_tier).to eq(1)
    expect(tier_two_users[-2].reload.league_tier).to eq(1)
  end

  it "does not move players between tiers when cohort is below minimum threshold" do
    category = Category.create!(name: "Under threshold settle")

    tier_two_users = (1..2).map { |i| create_user(index: 7000 + i, tier: 2) }
    tier_two_users.each_with_index do |user, idx|
      add_previous_week_xp(user, 500 - idx, category)
    end

    WeeklyLeague.settle_leagues_if_needed!(reference_time: settlement_reference_time)

    expect(tier_two_users.map { |user| user.reload.league_tier }.uniq).to eq([ 2 ])
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

  it "does not project movement in a tiny cohort" do
    category = Category.create!(name: "Small cohort")
    users = (1..2).map { |i| create_user(index: 2000 + i, tier: 2) }
    users.each_with_index { |user, idx| add_previous_week_xp(user, 400 - idx, category) }

    standings = WeeklyLeague.standings(User.where(id: users.map(&:id)).to_a, range: Time.current.all_week)

    expect(standings.map { |entry| entry[:projected_movement] }.uniq).to eq([ 0 ])
  end

  it "projects movement once cohort reaches three players" do
    category = Category.create!(name: "Minimum cohort")
    users = (1..3).map { |i| create_user(index: 2500 + i, tier: 2) }
    users.each_with_index { |user, idx| add_previous_week_xp(user, 600 - idx, category) }

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

    WeeklyLeague.settle_leagues_if_needed!(reference_time: settlement_reference_time)

    expect(bronze_users.map { |u| u.reload.league_tier }.min).to be >= 1
    expect(diamond_users.map { |u| u.reload.league_tier }.max).to be <= 5
  end

  it "does not settle before Sunday 19:00" do
    category = Category.create!(name: "Settlement schedule")
    users = (1..50).map { |i| create_user(index: 8000 + i, tier: 2) }
    users.each_with_index { |user, idx| add_previous_week_xp(user, 900 - idx, category) }

    before_cutoff = Time.zone.parse("2026-03-29 18:59:00")
    users.each { |user| user.update_columns(league_last_settled_week: WeeklyLeague.last_settlement_at(reference_time: before_cutoff).to_date) }
    WeeklyLeague.settle_leagues_if_needed!(reference_time: before_cutoff)

    expect(users.map { |u| u.reload.league_tier }.uniq).to eq([ 2 ])
  end

  it "settles at and after Sunday 19:00" do
    category = Category.create!(name: "Settlement cutoff")
    users = (1..50).map { |i| create_user(index: 9000 + i, tier: 2) }
    users.each_with_index { |user, idx| add_previous_week_xp(user, 900 - idx, category) }

    at_cutoff = Time.zone.parse("2026-03-29 19:00:00")
    users.each { |user| user.update_columns(league_last_settled_week: (at_cutoff.to_date - 7.days)) }
    WeeklyLeague.settle_leagues_if_needed!(reference_time: at_cutoff)

    expect(users.first.reload.league_tier).to eq(3)
    expect(users.last.reload.league_tier).to eq(1)
  end
end
