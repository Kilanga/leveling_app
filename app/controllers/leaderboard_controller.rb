class LeaderboardController < ApplicationController
  def index
    @players = User.order(xp: :desc).limit(10)
  end
end
