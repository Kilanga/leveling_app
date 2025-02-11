require "test_helper"

class UserQuestsControllerTest < ActionDispatch::IntegrationTest
  test "should get update" do
    get user_quests_update_url
    assert_response :success
  end
end
