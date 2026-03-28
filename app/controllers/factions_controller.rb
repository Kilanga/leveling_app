class FactionsController < ApplicationController
  before_action :authenticate_user!

  def join
    faction = Faction.find(params[:id])
    current_user.update!(faction: faction)
    redirect_to dashboard_path, notice: "Faction rejointe: #{faction.name}."
  end
end
