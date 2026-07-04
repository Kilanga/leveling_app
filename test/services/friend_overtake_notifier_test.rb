require "test_helper"

class FriendOvertakeNotifierTest < ActiveSupport::TestCase
  setup do
    @runner = create(:user)
    @friend = create(:user)
    Friendship.create!(user: @runner, friend: @friend, status: "accepted")
  end

  def complete_quest!(user, xp: 100)
    quest = create(:quest, xp: xp)
    create(:user_quest, user: user, quest: quest, completed: true)
  end

  test "notifie l'ami dépassé une seule fois par semaine" do
    complete_quest!(@friend, xp: 50)   # ami à 50 XP
    xp_before = 0
    complete_quest!(@runner, xp: 100)  # runner passe à 100 XP

    assert_difference -> { InAppNotification.where(user: @friend, kind: "friend_overtaken").count }, 1 do
      FriendOvertakeNotifier.call(@runner, xp_before: xp_before)
    end

    # L'ami repasse devant, le runner le redépasse : pas de doublon la même semaine
    complete_quest!(@friend, xp: 100)  # ami à 150, runner à 100
    complete_quest!(@runner, xp: 100)  # runner à 200
    assert_no_difference -> { InAppNotification.count } do
      FriendOvertakeNotifier.call(@runner, xp_before: 100)
    end
  end

  test "ne notifie pas si l'ami était déjà derrière" do
    complete_quest!(@friend, xp: 10)
    complete_quest!(@runner, xp: 50)   # runner déjà devant (50 > 10)
    complete_quest!(@runner, xp: 100)

    assert_no_difference -> { InAppNotification.count } do
      FriendOvertakeNotifier.call(@runner, xp_before: 50)
    end
  end

  test "ne notifie pas les demandes d'ami non acceptées" do
    pending_user = create(:user)
    Friendship.create!(user: @runner, friend: pending_user, status: "pending")
    complete_quest!(@runner, xp: 100)

    assert_no_difference -> { InAppNotification.where(user: pending_user).count } do
      FriendOvertakeNotifier.call(@runner, xp_before: 0)
    end
  end
end
