class Admin::AnalyticsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @events_last_7_days = ProductEvent.where("created_at >= ?", 7.days.ago)
    @event_counts = @events_last_7_days.group(:event_name).count

    @activation_users = ProductEvent.where(event_name: "onboarding_completed").where("created_at >= ?", 30.days.ago).distinct.count(:user_id)
    @quest_completions = ProductEvent.where(event_name: "quest_completed").where("created_at >= ?", 30.days.ago).count
    @shop_claims = ProductEvent.where(event_name: "shop_challenge_claimed").where("created_at >= ?", 30.days.ago).count
    @friend_challenges = ProductEvent.where(event_name: "friend_challenge_created").where("created_at >= ?", 30.days.ago).count

    period_start = 30.days.ago
    period_end = Time.current

    @funnel_signups_30d = User.where(created_at: period_start..period_end).count
    @funnel_onboarding_30d = ProductEvent.where(event_name: "onboarding_completed", created_at: period_start..period_end).distinct.count(:user_id)
    @funnel_first_quest_30d = ProductEvent.where(event_name: "quest_completed", created_at: period_start..period_end).distinct.count(:user_id)
    @funnel_shop_view_30d = ProductEvent.where(event_name: "shop_viewed", created_at: period_start..period_end).distinct.count(:user_id)
    @funnel_first_purchase_30d = ProductEvent.where(event_name: "purchase_completed", created_at: period_start..period_end).distinct.count(:user_id)

    @funnel_onboarding_rate = conversion_rate(@funnel_onboarding_30d, @funnel_signups_30d)
    @funnel_first_quest_rate = conversion_rate(@funnel_first_quest_30d, @funnel_signups_30d)
    @funnel_shop_view_rate = conversion_rate(@funnel_shop_view_30d, @funnel_signups_30d)
    @funnel_first_purchase_rate = conversion_rate(@funnel_first_purchase_30d, @funnel_signups_30d)
  end

  private

  def conversion_rate(numerator, denominator)
    return 0.0 if denominator.to_i <= 0

    ((numerator.to_f / denominator) * 100).round(1)
  end
end
