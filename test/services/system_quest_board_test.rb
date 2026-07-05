require "test_helper"

class SystemQuestBoardTest < ActiveSupport::TestCase
  def setup
    @user = create(:user, free_credits: 0)
    @category = create(:category, name: "Épreuve-#{SecureRandom.hex(3)}")
    @quest_a = create(:quest, category: @category, difficulty: "E", xp: 100, title: "Cible A #{SecureRandom.hex(2)}")
    @quest_b = create(:quest, category: @category, difficulty: "D", xp: 150, title: "Cible B #{SecureRandom.hex(2)}")
  end

  def assign!(quest, date: Time.zone.today, completed: false)
    @user.system_quest_assignments.create!(
      quest: quest,
      assigned_on: date,
      completed_at: completed ? Time.current : nil
    )
  end

  test "marque l'assignation du jour comme complétée" do
    assignment = assign!(@quest_a)
    assign!(@quest_b)

    result = SystemQuestBoard.register_completion!(@user, @quest_a)

    assert result.assignment.completed?
    refute result.perfect_day
    assert_equal assignment.id, result.assignment.id
  end

  test "retourne nil si la quête ne fait pas partie du jour" do
    assign!(@quest_a)

    assert_nil SystemQuestBoard.register_completion!(@user, @quest_b)
  end

  test "journée parfaite : bonus XP + Fragments, une seule fois" do
    assign!(@quest_a)
    assign!(@quest_b)

    SystemQuestBoard.register_completion!(@user, @quest_a)
    result = SystemQuestBoard.register_completion!(@user, @quest_b)

    assert result.perfect_day
    expected_bonus = ((100 + 150) * SystemQuestBoard::PERFECT_DAY_XP_RATIO).round
    assert_equal expected_bonus, result.bonus_xp
    assert_equal SystemQuestBoard::PERFECT_DAY_FRAGMENTS, @user.reload.free_credits_balance
    assert_equal Time.zone.today, @user.last_perfect_day_on
    assert_equal expected_bonus, @user.xp

    # Revalider ne redonne pas le bonus
    second = SystemQuestBoard.register_completion!(@user, @quest_b)
    refute second.perfect_day
    assert_equal SystemQuestBoard::PERFECT_DAY_FRAGMENTS, @user.reload.free_credits_balance
  end

  test "gel après 2 jours entièrement ratés" do
    assign!(@quest_a, date: Time.zone.today - 2.days)
    assign!(@quest_b, date: Time.zone.today - 1.day)
    assign!(@quest_a)

    assert SystemQuestBoard.weekly_progression_frozen?(@user)
  end

  test "pas de gel si un seul jour raté" do
    assign!(@quest_a, date: Time.zone.today - 2.days, completed: true)
    assign!(@quest_b, date: Time.zone.today - 1.day)
    assign!(@quest_a)

    refute SystemQuestBoard.weekly_progression_frozen?(@user)
  end

  test "pas de gel sans assignations passées" do
    assign!(@quest_a)

    refute SystemQuestBoard.weekly_progression_frozen?(@user)
  end

  test "compléter une quête du jour lève le gel" do
    assign!(@quest_a, date: Time.zone.today - 2.days)
    assign!(@quest_b, date: Time.zone.today - 1.day)
    assign!(@quest_a)

    assert SystemQuestBoard.weekly_progression_frozen?(@user)

    SystemQuestBoard.register_completion!(@user, @quest_a)

    refute SystemQuestBoard.weekly_progression_frozen?(@user)
  end
end
