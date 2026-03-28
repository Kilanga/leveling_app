class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :ensure_profile_completed
  skip_before_action :resolve_due_friend_challenges
  skip_before_action :set_unread_notifications_count

  def terms
    # Static page, no logic needed
  end

  def privacy
    # Static page, no logic needed
  end

  def sitemap
    @public_urls = [
      root_url,
      welcome_url,
      terms_url,
      privacy_url,
      new_user_registration_url,
      new_user_session_url
    ]

    render :sitemap, formats: :xml
  end
end
