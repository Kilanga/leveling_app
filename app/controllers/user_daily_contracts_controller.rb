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
      redirect_to dashboard_path, notice: I18n.t("flash.daily_contracts.reward_claimed", amount: contract.daily_contract.reward_coins)
    else
      redirect_to dashboard_path, alert: I18n.t("errors.messages.reward_not_available")
    end
  end
end
