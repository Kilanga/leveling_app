class DashboardController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: [ :index ]

  def index
    @user_quests = current_user.user_quests.includes(:quest)
    @stats = current_user.user_stats.includes(:category)
  end
end
