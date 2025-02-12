require "test_helper"

class LeaderboardControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user, confirmed_at: Time.current)
    sign_in @user
  end


  test "should get index" do
    get leaderboard_index_url
    assert_response :success
  end
end
