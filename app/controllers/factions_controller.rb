class FactionsController < ApplicationController
  before_action :authenticate_user!

  def join
    faction = Faction.find(params[:id])

    current_user.with_lock do
      current_user.reload

      if current_user.faction_id == faction.id
        redirect_to dashboard_path, notice: I18n.t('flash.factions.already_member', name: faction.name)
        return
      end

      unless current_user.can_change_faction?
        available_at = current_user.faction_switch_available_at
        readable_time = available_at.present? ? I18n.l(available_at, format: :short) : I18n.t('common.next_reset')
        redirect_to dashboard_path, alert: I18n.t('flash.factions.change_locked', time: readable_time)
        return
      end

      current_user.update!(faction: faction, faction_joined_at: Time.current)
    end

    redirect_to dashboard_path, notice: I18n.t('flash.factions.faction_joined', name: faction.name)
  end
end
