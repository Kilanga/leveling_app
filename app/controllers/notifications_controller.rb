class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.in_app_notifications.order(created_at: :desc).limit(100)
  end

  def update
    notification = current_user.in_app_notifications.find(params[:id])
    notification.mark_as_read!
    redirect_to(notification.cta_path.presence || notifications_path)
  end

  def mark_all_read
    current_user.in_app_notifications.unread.update_all(read_at: Time.current)
    redirect_to notifications_path, notice: I18n.t('flash.notifications.marked_as_read')
  end
end
