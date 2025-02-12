require "test_helper"

class QuestsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user, confirmed_at: Time.current) # ✅ Ajout de la confirmation
    sign_in @user # ✅ Connexion
    @quest = create(:quest) # ✅ Assure-toi qu'une quête existe
  end

  test "should get index" do
    get quests_url
    assert_response :success
  end

  test "should get show" do
    get quest_url(@quest)
    assert_response :success
  end
end
