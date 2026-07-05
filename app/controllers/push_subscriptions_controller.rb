class PushSubscriptionsController < ApplicationController
  skip_before_action :ensure_profile_completed, raise: false

  def create
    subscription = PushSubscription.find_or_initialize_by(endpoint: subscription_params[:endpoint])
    subscription.assign_attributes(subscription_params.merge(user: current_user))

    if subscription.save
      head :created
    else
      head :unprocessable_entity
    end
  end

  def destroy
    current_user.push_subscriptions.find_by(endpoint: params[:endpoint])&.destroy
    head :no_content
  end

  private

  def subscription_params
    params.require(:push_subscription).permit(:endpoint, :p256dh_key, :auth_key)
  end
end
