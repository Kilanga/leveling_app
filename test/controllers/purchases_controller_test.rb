require "test_helper"

class PurchasesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user, confirmed_at: Time.current)
    sign_in @user
  end


  test "should get new" do
    get new_purchase_url
    assert_response :success
  end

  test "should post create with invalid params" do
    post purchases_url
    assert_response :redirect
  end
end
