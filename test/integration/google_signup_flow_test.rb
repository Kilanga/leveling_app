require "test_helper"

# Vérifie le contrat fonctionnel : un compte créé via Google doit
# obligatoirement passer par l'écran de choix du pseudo avant de naviguer.
class GoogleSignupFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def google_auth_hash
    OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "google-uid-123",
      info: { email: "nouveau@example.com", name: "Nouveau Chasseur" }
    )
  end

  test "from_google_oauth2 crée un compte au profil incomplet" do
    user = User.from_google_oauth2(google_auth_hash)

    assert user.persisted?
    assert_equal "google_oauth2", user.provider
    assert user.pseudo.present?, "un pseudo provisoire doit être généré"
    assert user.needs_profile_completion?, "le choix du pseudo doit être requis"

    # Reconnexion : le compte existant est retrouvé, pas dupliqué
    assert_no_difference -> { User.count } do
      User.from_google_oauth2(google_auth_hash)
    end
  end

  test "un compte Google incomplet est verrouillé sur l'écran de choix du pseudo" do
    user = User.from_google_oauth2(google_auth_hash)
    sign_in user

    get quests_path
    assert_redirected_to complete_profile_path

    follow_redirect!
    assert_response :success
    assert_includes response.body, I18n.t("complete_profile.username_label")
  end

  test "choisir son pseudo débloque la navigation" do
    user = User.from_google_oauth2(google_auth_hash)
    sign_in user

    patch complete_profile_path, params: { user: {
      pseudo: "OmbreDuLundi",
      avatar: "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
    } }
    assert_redirected_to root_path

    user.reload
    assert_equal "OmbreDuLundi", user.pseudo
    assert_not user.needs_profile_completion?

    get quests_path
    assert_response :success
  end

  test "une reconnexion d'un profil complété ne repasse pas par l'écran" do
    user = User.from_google_oauth2(google_auth_hash)
    user.update!(pseudo: "DejaFait", profile_completed: true)
    sign_in user

    get quests_path
    assert_response :success
  end
end
