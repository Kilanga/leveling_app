class FactionsController < ApplicationController
  before_action :authenticate_user!

  def join
    faction = Faction.find(params[:id])

    current_user.with_lock do
      current_user.reload

      if current_user.faction_id == faction.id
        redirect_to dashboard_path, notice: "Tu fais deja partie de #{faction.name}."
        return
      end

      unless current_user.can_change_faction?
        available_at = current_user.faction_switch_available_at
        readable_time = available_at.present? ? I18n.l(available_at, format: :short) : "le prochain reset"
        redirect_to dashboard_path, alert: "Changement de faction verrouille jusqu'au reset hebdomadaire (#{readable_time})."
        return
      end

      current_user.update!(faction: faction, faction_joined_at: Time.current)
    end

    redirect_to dashboard_path, notice: "Faction rejointe: #{faction.name}."
  end
end
