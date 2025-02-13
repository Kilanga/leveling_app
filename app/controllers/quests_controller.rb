class QuestsController < ApplicationController
  before_action :authenticate_user!

  def index
    @quests = Quest.includes(:category)

    if params[:query].present?
      @quests = @quests.where("title ILIKE ?", "%#{params[:query]}%")
    end

    if params[:category_id].present?
      @quests = @quests.where(category_id: params[:category_id])
    end
  end

  def show
    @quest = Quest.find(params[:id])
    @user_quest = current_user.user_quests.find_or_initialize_by(quest: @quest)
  end
end
