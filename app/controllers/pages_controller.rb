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

  def credentials
    render layout: false
  end

  def guilde_et_cie_privacy
    # Static page, no logic needed
  end

  def guilde_et_cie_account_deletion
    # Static page, no logic needed
  end

  def sitemap
    @public_urls = [
      root_url,
      welcome_url,
      terms_url,
      privacy_url,
      guilde_et_cie_privacy_url,
      guilde_et_cie_account_deletion_url,
      new_user_registration_url
    ]

    render :sitemap, formats: :xml
  end
end
