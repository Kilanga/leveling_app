class QuestsController < ApplicationController
  before_action :authenticate_user!

  def index
    @quests = Quest.includes(:category).all
  end

  def show
    @quest = Quest.find(params[:id])
    @user_quest = current_user.user_quests.find_or_initialize_by(quest: @quest)
  end
end
