require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user, confirmed_at: Time.current)
    sign_in @user
  end
  test "should get index" do
    get dashboard_index_url
    assert_response :success
  end
end
