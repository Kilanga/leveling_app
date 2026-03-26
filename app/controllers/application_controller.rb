class ApplicationController < ActionController::Base
  before_action :authenticate_user!, unless: :devise_controller?
  before_action :ensure_profile_completed
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def authenticate_admin!
    authenticate_user!
    redirect_to root_path, alert: "Accès interdit." unless current_user&.admin?
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:pseudo, :avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: [:pseudo, :avatar])
  end

  def ensure_profile_completed
    return unless user_signed_in?
    return unless current_user.needs_profile_completion?
    return if controller_name == "users" && ["complete_profile", "update_profile"].include?(action_name)

    redirect_to complete_profile_path
  end
end
