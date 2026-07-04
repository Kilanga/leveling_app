require "test_helper"

class StreakReminderTest < ActiveSupport::TestCase
  setup do
    # Streak active, mais aucune complétion cette semaine
    @user = create(:user, weekly_streak_count: 3,
                          weekly_streak_last_completed_on: Date.current.beginning_of_week - 3.days)
  end

  test "envoie un rappel en fin de semaine" do
    friday = Date.current.beginning_of_week + 4.days
    assert_difference -> { InAppNotification.where(user: @user, kind: "streak_reminder").count }, 1 do
      assert_equal 1, StreakReminder.call(today: friday)
    end
  end

  test "n'envoie rien en début de semaine" do
    tuesday = Date.current.beginning_of_week + 1.day
    assert_equal 0, StreakReminder.call(today: tuesday)
  end

  test "pas de doublon la même semaine" do
    friday = Date.current.beginning_of_week + 4.days
    StreakReminder.call(today: friday)
    assert_no_difference -> { InAppNotification.count } do
      assert_equal 0, StreakReminder.call(today: friday.next_day)
    end
  end

  test "ignore les joueurs déjà actifs cette semaine" do
    @user.update!(weekly_streak_last_completed_on: Date.current.beginning_of_week)
    friday = Date.current.beginning_of_week + 4.days
    assert_equal 0, StreakReminder.call(today: friday)
  end
end
