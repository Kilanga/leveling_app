class AchievementsController < ApplicationController
  def index
    @achievements = TitleUnlocker.progress_for(current_user)
    @unlocked_count = @achievements.count { |a| a[:owned] || a[:unlocked] }
  end
end
