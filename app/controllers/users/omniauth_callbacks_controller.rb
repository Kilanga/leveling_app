class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth = request.env["omniauth.auth"]
    user = User.from_google_oauth2(auth)

    sign_in user, event: :authentication
    if user.needs_profile_completion?
      redirect_to complete_profile_path
    else
      redirect_to root_path
    end
  rescue StandardError => e
    Rails.logger.error("Google OAuth error: #{e.class} - #{e.message}")
    redirect_to new_user_registration_path, alert: I18n.t("flash.google_login_failed")
  end

  def failure
    redirect_to new_user_session_path
  end
end
