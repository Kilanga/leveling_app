class DailyContractsController < ApplicationController
  before_action :authenticate_user!

  def accept
    contract = DailyContract.find(params[:id])
    unless contract.active_on == Time.zone.today
      redirect_to dashboard_path, alert: "Ce contrat n'est plus disponible."
      return
    end

    accepted = false
    current_user.with_lock do
      offer = current_user.user_daily_contracts.find_or_create_by!(daily_contract: contract)

      active_contract = current_user.user_daily_contracts
        .joins(:daily_contract)
        .where(status: "accepted", daily_contracts: { active_on: Time.zone.today })
        .where.not(id: offer.id)
        .exists?

      if active_contract
        redirect_to dashboard_path, alert: "Tu as deja un contrat actif aujourd'hui."
        return
      end

      accepted = offer.accept!
      accepted ||= offer.accepted? || offer.completed?
    end

    if accepted
      redirect_to dashboard_path, notice: "Contrat accepte."
    else
      redirect_to dashboard_path, alert: "Contrat indisponible."
    end
  end
end
