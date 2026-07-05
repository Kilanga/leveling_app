require "test_helper"

class GoogleSignupFlowTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "google-uid-123",
      info: { email: "nouveau@example.com", name: "Nouveau Chasseur" }
    )
  end

  teardown do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end

  test "un nouveau compte Google passe par le choix du pseudo" do
    post "/users/auth/google_oauth2"
    follow_redirect! # -> callback

    user = User.find_by(uid: "google-uid-123")
    assert user.present?, "l'utilisateur Google doit être créé"
    assert user.needs_profile_completion?, "le profil doit être marqué incomplet"
    assert_redirected_to complete_profile_path

    # L'écran de complétion s'affiche avec le champ pseudo
    follow_redirect!
    assert_response :success
    assert_includes response.body, I18n.t("complete_profile.username_label")

    # L'utilisateur choisit son pseudo et son avatar
    patch complete_profile_path, params: { user: {
      pseudo: "OmbreDuLundi",
      avatar: "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
    } }
    assert_redirected_to root_path

    user.reload
    assert_equal "OmbreDuLundi", user.pseudo
    assert user.profile_completed?
    assert_not user.needs_profile_completion?
  end

  test "une reconnexion Google d'un profil complété ne repasse pas par l'écran" do
    post "/users/auth/google_oauth2"
    follow_redirect!
    User.find_by(uid: "google-uid-123").update!(profile_completed: true, pseudo: "DejaFait")

    post "/users/auth/google_oauth2"
    follow_redirect!
    assert_redirected_to root_path
  end

  test "impossible de naviguer ailleurs tant que le profil n'est pas complété" do
    post "/users/auth/google_oauth2"
    follow_redirect!

    get quests_path
    assert_redirected_to complete_profile_path
  end
end
