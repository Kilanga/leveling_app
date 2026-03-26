class ApplicationController < ActionController::Base
  before_action :authenticate_user!, unless: :devise_controller?
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
end
