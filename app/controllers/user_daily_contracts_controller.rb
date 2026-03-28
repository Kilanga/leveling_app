class UserDailyContractsController < ApplicationController
  before_action :authenticate_user!

  def claim
    contract = current_user.user_daily_contracts.find(params[:id])

    if contract.claim_reward!
      ProductAnalytics.track(
        user: current_user,
        event_name: "daily_contract_claimed",
        metadata: { daily_contract_id: contract.daily_contract_id, reward_free_credits: contract.daily_contract.reward_coins }
      )
      redirect_to dashboard_path, notice: "Prime recuperee: +#{contract.daily_contract.reward_coins} credits gratuits."
    else
      redirect_to dashboard_path, alert: "Prime non disponible."
    end
  end
end
