require "test_helper"

class FactionBossTest < ActiveSupport::TestCase
  setup do
    @faction = Faction.first || Faction.create!(name: "Test Faction", slug: "test-faction", color_hex: "#123456")
    @member = create(:user)
    @member.update_column(:faction_id, @faction.id)
  end

  test "récompense tous les membres quand la cible est atteinte, une seule fois" do
    FactionInfluence.add_points!(faction: @faction, points: FactionBoss::TARGET_POINTS)

    assert FactionBoss.check!(@faction)
    assert_equal FactionBoss::REWARD_FRAGMENTS, @member.reload.free_credits
    assert InAppNotification.where(user: @member, kind: "faction_boss_defeated").exists?

    # Second passage : déjà récompensé
    assert_not FactionBoss.check!(@faction)
    assert_equal FactionBoss::REWARD_FRAGMENTS, @member.reload.free_credits
  end

  test "ne récompense pas sous la cible" do
    FactionInfluence.add_points!(faction: @faction, points: FactionBoss::TARGET_POINTS - 1)
    assert_not FactionBoss.check!(@faction)
    assert_equal 0, @member.reload.free_credits
  end

  test "progress_for expose points, cible et ratio" do
    FactionInfluence.add_points!(faction: @faction, points: 5)
    progress = FactionBoss.progress_for(@faction)
    assert_equal 5, progress[:points]
    assert_equal FactionBoss::TARGET_POINTS, progress[:target]
    assert_not progress[:defeated]
  end
end
