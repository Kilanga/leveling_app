require "test_helper"

class Admin::QuestsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def before_setup
    super
    @admin = create(:user, admin: true)
    @quest = create(:quest) # Vérifie que tu as bien une quest définie dans test/fixtures/quests.yml
    sign_in @admin
  end

  test "should get index" do
    get admin_quests_path
    assert_response :success
  end

  test "should get new" do
    get new_admin_quest_path  # Correction
    assert_response :success
  end

  test "should create quest" do
    post admin_quests_path, params: { quest: { title: "New Quest", description: "Quest details" } } # Correction
    assert_response :redirect # Généralement, create redirige après succès
  end

  test "should get edit" do
    get edit_admin_quest_path(@quest)  # Correction
    assert_response :success
  end

  test "should update quest" do
    patch admin_quest_path(@quest), params: { quest: { title: "Updated Title" } } # Correction
    assert_response :redirect
  end

  test "should destroy quest" do
    delete admin_quest_path(@quest)  # Correction
    assert_response :redirect
  end
end
puts Quest.all.inspect
