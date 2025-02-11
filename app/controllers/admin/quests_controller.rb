class Admin::QuestsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  def index
    @quests = Quest.all
  end

  def new
    @quest = Quest.new
  end

  def create
    @quest = Quest.new(quest_params)
    if @quest.save
      redirect_to admin_quests_path, notice: "Quête créée avec succès."
    else
      render :new
    end
  end

  def edit
    @quest = Quest.find(params[:id])
  end

  def update
    @quest = Quest.find(params[:id])
    if @quest.update(quest_params)
      redirect_to admin_quests_path, notice: "Quête mise à jour."
    else
      render :edit
    end
  end

  def destroy
    @quest = Quest.find(params[:id])
    @quest.destroy
    redirect_to admin_quests_path, alert: "Quête supprimée."
  end

  private

  def quest_params
    params.require(:quest).permit(:title, :description, :xp, :category_id, :valid_until)
  end

  def check_admin
    redirect_to root_path, alert: "Accès interdit." unless current_user.admin?
  end
end
