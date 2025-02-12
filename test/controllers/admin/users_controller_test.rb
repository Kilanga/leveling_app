require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user, :admin) # ✅ Maintenant, il a le bon trait
    sign_in @user # ✅ Connexion
  end

  test "should get index" do
    get admin_users_path
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_user_path(@user)
    assert_response :success
  end

  test "should get update" do
    patch admin_user_path(@user), params: { user: { email: "new@example.com" } }
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end
end
