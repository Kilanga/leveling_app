class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!, only: :index
  skip_before_action :ensure_profile_completed, only: :index
  skip_before_action :resolve_due_friend_challenges, only: :index
  skip_before_action :set_unread_notifications_count, only: :index

  def index
    if user_signed_in?
      redirect_to dashboard_path
      return
    end

    @players_count = User.count
    @quests_count = Quest.count
    @categories_count = Category.count
    @invite_ref = params[:ref].to_s.upcase.presence
    @signup_params = {
      ref: @invite_ref,
      utm_source: params[:utm_source].presence || "organic",
      utm_campaign: params[:utm_campaign].presence || "welcome_launch"
    }.compact
  end
end
