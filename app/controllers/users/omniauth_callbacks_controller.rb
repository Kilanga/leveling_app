class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth = request.env["omniauth.auth"]
    user = User.from_google_oauth2(auth)

    sign_in_and_redirect user, event: :authentication
  rescue StandardError => e
    Rails.logger.error("Google OAuth error: #{e.class} - #{e.message}")
    redirect_to new_user_registration_path, alert: "Connexion Google impossible."
  end

  def failure
    redirect_to new_user_session_path
  end
end
