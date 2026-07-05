require "test_helper"

class SystemQuestAssignerTest < ActiveSupport::TestCase
  def setup
    @user = create(:user)
    @weak_category = create(:category, name: "Faible-#{SecureRandom.hex(3)}")
    @strong_category = create(:category, name: "Forte-#{SecureRandom.hex(3)}")
    create(:user_stat, user: @user, category: @weak_category, level: 1)
    create(:user_stat, user: @user, category: @strong_category, level: 9)

    # Catalogue accessible à un rang E (E/D uniquement)
    6.times do |i|
      create(:quest, category: @weak_category, difficulty: "E", xp: 100, title: "Quête faible #{i}-#{SecureRandom.hex(2)}")
      create(:quest, category: @strong_category, difficulty: "D", xp: 150, title: "Quête forte #{i}-#{SecureRandom.hex(2)}")
    end
  end

  test "assigne 3 ou 4 quêtes du jour" do
    assignments = SystemQuestAssigner.assign_for!(@user)

    assert_includes 3..4, assignments.size
    assert assignments.all? { |a| a.assigned_on == Time.zone.today }
  end

  test "idempotent : relancer le même jour ne change rien" do
    first = SystemQuestAssigner.assign_for!(@user).map(&:id).sort
    second = SystemQuestAssigner.assign_for!(@user).map(&:id).sort

    assert_equal first, second
    assert_equal first.size, @user.system_quest_assignments.for_day(Time.zone.today).count
  end

  test "la difficulté est alignée sur le rang du chasseur" do
    create(:quest, category: @weak_category, difficulty: "S", xp: 600, title: "Quête rang S #{SecureRandom.hex(2)}")

    assignments = SystemQuestAssigner.assign_for!(@user)

    assignments.each do |assignment|
      assert_includes %w[E D], assignment.quest.difficulty,
        "Un rang E ne doit recevoir que des quêtes E/D"
    end
  end

  test "pondère vers les catégories faibles" do
    # Sur beaucoup de tirages (jours différents), la catégorie faible
    # doit être nettement plus servie que la forte (poids 1/2 vs 1/10).
    weak_count = 0
    strong_count = 0

    30.times do |i|
      date = Time.zone.today + i.days
      SystemQuestAssigner.assign_for!(@user, date: date).each do |assignment|
        weak_count += 1 if assignment.quest.category_id == @weak_category.id
        strong_count += 1 if assignment.quest.category_id == @strong_category.id
      end
    end

    assert_operator weak_count, :>, strong_count,
      "La catégorie faible (#{weak_count}) doit dominer la forte (#{strong_count})"
  end

  test "assign_all! couvre tous les joueurs" do
    other = create(:user)
    SystemQuestAssigner.assign_all!

    assert_operator @user.system_quest_assignments.for_day(Time.zone.today).count, :>=, 3
    assert_operator other.system_quest_assignments.for_day(Time.zone.today).count, :>=, 3
  end
end
