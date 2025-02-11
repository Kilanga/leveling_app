require "test_helper"

class Admin::QuestsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_quests_index_url
    assert_response :success
  end

  test "should get new" do
    get admin_quests_new_url
    assert_response :success
  end

  test "should get create" do
    get admin_quests_create_url
    assert_response :success
  end

  test "should get edit" do
    get admin_quests_edit_url
    assert_response :success
  end

  test "should get update" do
    get admin_quests_update_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_quests_destroy_url
    assert_response :success
  end
end
