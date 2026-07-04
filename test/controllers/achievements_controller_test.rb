class AchievementsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user, confirmed_at: Time.current)
    sign_in @user
  end

  test "affiche la page succès avec les 7 titres et leur progression" do
    get achievements_url
    assert_response :success
    assert_includes response.body, I18n.t("achievements.index.page_title")
    TitleUnlocker::TITLE_DEFINITIONS.each do |definition|
      assert_includes response.body, definition[:name]
    end
  end

  test "redirige les visiteurs non connectés" do
    sign_out @user
    get achievements_url
    assert_redirected_to new_user_session_path
  end
end
