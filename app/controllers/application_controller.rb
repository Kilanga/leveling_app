class ApplicationController < ActionController::Base
  before_action :authenticate_user!, unless: :devise_controller?
  before_action :ensure_profile_completed
  before_action :resolve_due_friend_challenges
  before_action :set_unread_notifications_count
  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :track_page_view

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
    return if devise_controller?
    return unless user_signed_in?
    return unless current_user.needs_profile_completion?
    return if controller_name == "users" && ["complete_profile", "update_profile"].include?(action_name)

    redirect_to complete_profile_path
  end

  def resolve_due_friend_challenges
    FriendChallengeResolver.resolve_due_challenges!
  rescue StandardError => e
    Rails.logger.warn("Friend challenge resolver failed: #{e.class} #{e.message}")
  end

  def set_unread_notifications_count
    return unless user_signed_in?

    @unread_notifications_count = current_user.in_app_notifications.unread.count
  end

  def track_page_view
    return unless user_signed_in?
    return if devise_controller?

    ProductAnalytics.track(
      user: current_user,
      event_name: "page_view",
      metadata: { controller: controller_name, action: action_name, path: request.path }
    )
  end
end
