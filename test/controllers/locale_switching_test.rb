class LocaleSwitchingTest < ActionDispatch::IntegrationTest
  test "welcome page renders in French by default" do
    get root_url
    assert_response :success
    assert_includes response.body, I18n.t("welcome.index.main_heading", locale: :fr)
  end

  test "?locale=en switches to English and persists in session" do
    get root_url(locale: "en")
    assert_response :success
    assert_includes response.body, I18n.t("welcome.index.main_heading", locale: :en)

    # La locale persiste sans le paramètre
    get root_url
    assert_includes response.body, I18n.t("welcome.index.main_heading", locale: :en)
  end

  test "invalid locale falls back to default" do
    get root_url(locale: "xx")
    assert_response :success
    assert_includes response.body, I18n.t("welcome.index.main_heading", locale: :fr)
  end
end
