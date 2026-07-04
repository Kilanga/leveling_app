class UserQuestsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user, confirmed_at: Time.current)
    sign_in @user
  end

  test "complete marks the quest completed and redirects to root" do
    quest = create(:quest)
    user_quest = create(:user_quest, user: @user, quest: quest, progress: 0, active: true)

    patch user_quest_url(user_quest), params: { action_type: "complete" }

    assert_redirected_to root_path
    user_quest.reload
    assert user_quest.completed, "la quête devrait être marquée complétée"
    assert_not user_quest.active, "la quête devrait être désactivée après complétion"
  end

  test "unknown action_type redirects to root with alert" do
    quest = create(:quest)
    user_quest = create(:user_quest, user: @user, quest: quest, progress: 0, active: true)

    patch user_quest_url(user_quest), params: { user_quest: { completed: true } }

    assert_redirected_to root_path
    assert_not user_quest.reload.completed, "la quête ne doit pas être complétée sans action_type"
  end
end
