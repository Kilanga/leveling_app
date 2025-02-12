require "test_helper"

class PurchasesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user, confirmed_at: Time.current)
    sign_in @user
  end


  test "should get new" do
    get purchases_new_url
    assert_response :success
  end

  test "should get create" do
    get purchases_create_url
    assert_response :success
  end
end
