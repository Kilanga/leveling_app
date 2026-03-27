class UserQuestsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user, confirmed_at: Time.current)
    sign_in @user
  end

  test "should get update" do
    quest = create(:quest) # S'assurer qu'une quête existe
    user_quest = create(:user_quest, user: @user, quest: quest, progress: 0)
    patch user_quest_url(user_quest), params: { user_quest: { completed: true } }
    assert_response :success
  end
end
