class Admin::AnalyticsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @events_last_7_days = ProductEvent.where("created_at >= ?", 7.days.ago)
    @event_counts = @events_last_7_days.group(:event_name).count

    @activation_users = ProductEvent.where(event_name: "onboarding_completed").where("created_at >= ?", 30.days.ago).distinct.count(:user_id)
    @quest_completions = ProductEvent.where(event_name: "quest_completed").where("created_at >= ?", 30.days.ago).count
    @shop_claims = ProductEvent.where(event_name: "shop_challenge_claimed").where("created_at >= ?", 30.days.ago).count
    @friend_challenges = ProductEvent.where(event_name: "friend_challenge_created").where("created_at >= ?", 30.days.ago).count
  end
end
