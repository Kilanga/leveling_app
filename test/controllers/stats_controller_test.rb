class StatsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user, confirmed_at: Time.current)
    sign_in @user
  end

  test "affiche la page stats avec la série hebdo" do
    quest = create(:quest, xp: 80)
    create(:user_quest, user: @user, quest: quest, completed: true, progress: 0)

    get stats_url
    assert_response :success
    assert_includes response.body, I18n.t("stats.show.page_title")
    assert_includes response.body, "weeklyStatsChart"
  end

  test "redirige les visiteurs non connectés" do
    sign_out @user
    get stats_url
    assert_redirected_to new_user_session_path
  end
end
