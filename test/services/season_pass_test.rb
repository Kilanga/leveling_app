require "test_helper"

class SeasonPassTest < ActiveSupport::TestCase
  def setup
    @user = create(:user, free_credits: 0, coins: 0)
    @season = SeasonManager.current!
  end

  def give_season_xp(amount)
    SeasonManager.add_xp!(@user, amount)
  end

  test "state_for expose paliers, déblocage et réclamations" do
    give_season_xp(800)

    state = SeasonPass.state_for(@user, @season)

    assert_equal 800, state[:xp]
    refute state[:premium]
    assert state[:tiers][0][:unlocked]  # palier 1 (300 XP)
    assert state[:tiers][1][:unlocked]  # palier 2 (700 XP)
    refute state[:tiers][2][:unlocked]  # palier 3 (1200 XP)
    assert_equal 3, state[:next_tier][:tier]
  end

  test "claim! piste gratuite : crédite la récompense une seule fois" do
    give_season_xp(300)

    reward = SeasonPass.claim!(@user, @season, tier: 1, track: "free")

    assert_equal 40, reward[:fragments]
    assert_equal 40, @user.reload.free_credits_balance

    assert_nil SeasonPass.claim!(@user, @season, tier: 1, track: "free")
    assert_equal 40, @user.reload.free_credits_balance
  end

  test "claim! refuse un palier non atteint" do
    give_season_xp(100)

    assert_nil SeasonPass.claim!(@user, @season, tier: 1, track: "free")
  end

  test "claim! premium exige la piste premium" do
    give_season_xp(300)

    assert_nil SeasonPass.claim!(@user, @season, tier: 1, track: "premium")

    SeasonPass.unlock_premium!(@user, @season, transaction_id: "tx-test")
    reward = SeasonPass.claim!(@user, @season, tier: 1, track: "premium")

    assert_equal 60, reward[:orbs]
    assert_equal 60, @user.reload.coins
  end

  test "palier 10 premium accorde le titre exclusif" do
    give_season_xp(7500)
    SeasonPass.unlock_premium!(@user, @season)

    reward = SeasonPass.claim!(@user, @season, tier: 10, track: "premium")

    assert reward[:title]
    title = ShopItem.find_by(name: "Élu de la Saison #{@season.number}", item_type: "title")
    assert title.present?
    assert @user.user_items.exists?(shop_item: title)
  end

  test "unlock_premium! est idempotent" do
    first = SeasonPass.unlock_premium!(@user, @season, transaction_id: "tx-1")
    second = SeasonPass.unlock_premium!(@user, @season, transaction_id: "tx-2")

    assert_equal first.id, second.id
    assert SeasonPass.premium?(@user, @season)
  end

  test "la récompense boost étend boost_expires_at" do
    give_season_xp(1800)

    SeasonPass.unlock_premium!(@user, @season)
    SeasonPass.claim!(@user, @season, tier: 4, track: "premium")

    assert @user.reload.boost_expires_at > 23.hours.from_now
  end
end
