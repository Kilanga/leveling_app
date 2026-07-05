require "test_helper"

class SeasonManagerTest < ActiveSupport::TestCase
  test "current! crée une saison de 6 semaines couvrant la date" do
    season = SeasonManager.current!

    assert season.active?
    assert_equal 41, (season.ends_on - season.starts_on).to_i # 6 semaines - 1 jour
    assert_equal 1, season.number
    assert_includes season.name, "Saison 1"
  end

  test "current! est idempotent" do
    first = SeasonManager.current!
    second = SeasonManager.current!

    assert_equal first.id, second.id
  end

  test "les saisons s'enchaînent sans trou après une longue inactivité" do
    first = SeasonManager.current!
    far_future = first.ends_on + 15.weeks

    future_season = SeasonManager.current!(far_future)

    assert future_season.active?(far_future)
    assert_operator future_season.number, :>, first.number
    # Continuité du calendrier : chaque saison commence le lendemain de la précédente
    seasons = Season.order(:number).to_a
    seasons.each_cons(2) do |a, b|
      assert_equal a.ends_on + 1.day, b.starts_on
    end
  end

  test "add_xp! cumule l'XP saisonnier du joueur" do
    user = create(:user)

    SeasonManager.add_xp!(user, 100)
    SeasonManager.add_xp!(user, 150)
    SeasonManager.add_xp!(user, 0)

    season = SeasonManager.current!
    assert_equal 250, season.user_seasons.find_by(user: user).xp
  end

  test "rank_for classe par XP décroissant" do
    season = SeasonManager.current!
    alice = create(:user)
    bob = create(:user)
    idle = create(:user)

    SeasonManager.add_xp!(alice, 500)
    SeasonManager.add_xp!(bob, 200)

    assert_equal 1, SeasonManager.rank_for(alice, season)
    assert_equal 2, SeasonManager.rank_for(bob, season)
    assert_nil SeasonManager.rank_for(idle, season)
  end

  test "close! attribue badge au top 10% et titre unique au top 3" do
    season = Season.create!(
      number: 99, name: "Saison 99 — Test",
      starts_on: 7.weeks.ago.to_date, ends_on: 1.week.ago.to_date
    )

    players = 10.times.map { |i| create(:user) }
    players.each_with_index do |player, index|
      season.user_seasons.create!(user: player, xp: 1000 - index * 50)
    end

    SeasonManager.close!(season)

    assert season.reload.closed?

    badge = Badge.find_by(name: "Élite — #{season.name}")
    assert badge.present?
    # top 10% de 10 joueurs = 1, mais minimum top 3
    assert_equal 3, UserBadge.where(badge: badge).count

    title = ShopItem.find_by(name: "Souverain de la Saison 99", item_type: "title")
    assert title.present?
    assert_equal 3, UserItem.where(shop_item: title).count
    assert players[0].user_items.exists?(shop_item: title)
    refute players[3].user_items.exists?(shop_item: title)

    # Idempotent : re-clôturer ne double pas les récompenses
    season.update!(closed_at: nil)
    SeasonManager.close!(season)
    assert_equal 3, UserItem.where(shop_item: title).count
  end

  test "close_finished_seasons! clôture et garantit une saison courante" do
    Season.create!(
      number: 1, name: "Saison 1 — Ancienne",
      starts_on: 8.weeks.ago.to_date, ends_on: 2.weeks.ago.to_date
    )

    SeasonManager.close_finished_seasons!

    assert Season.find_by(number: 1).closed?
    assert Season.covering(Time.zone.today).exists?
  end

  test "l'XP d'une quête alimente le ledger saisonnier via XpAwarder" do
    user = create(:user)
    category = create(:category, name: "Saison-#{SecureRandom.hex(3)}")
    quest = create(:quest, category: category, xp: 220, difficulty: "C")
    user_quest = create(:user_quest, user: user, quest: quest, active: true, completed: false, progress: 0)

    gained = XpAwarder.complete_user_quest!(user_quest)

    season = SeasonManager.current!
    assert_equal gained, season.user_seasons.find_by(user: user).xp
  end
end
