require "test_helper"

class DripSchedulerTest < ActiveSupport::TestCase
  test "envoie le mail J+3 aux inscrits d'il y a 3 jours" do
    create(:user, created_at: 3.days.ago - 2.hours)
    create(:user, created_at: 1.day.ago) # trop récent
    counts = DripScheduler.call
    assert_equal 1, counts[:day3]
  end

  test "réactive les inactifs de 14 jours, avec déduplication 30 jours" do
    inactive = create(:user, created_at: 20.days.ago)
    counts = DripScheduler.call
    assert_equal 1, counts[:reactivation]
    assert InAppNotification.where(user: inactive, kind: "reactivation").exists?

    # Deuxième run : dédupliqué
    assert_equal 0, DripScheduler.call[:reactivation]
  end

  test "ignore les joueurs actifs récemment" do
    active = create(:user, created_at: 20.days.ago)
    quest = create(:quest)
    create(:user_quest, user: active, quest: quest, completed: true, progress: 0)
    assert_equal 0, DripScheduler.call[:reactivation]
  end
end
