class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  def create
    webhook_secrets = Array(Rails.configuration.stripe[:webhook_secrets])
    return head :unprocessable_entity if webhook_secrets.empty?

    payload = request.body.read
    signature = request.env["HTTP_STRIPE_SIGNATURE"]

    event = nil
    webhook_secrets.each do |secret|
      begin
        event = Stripe::Webhook.construct_event(payload, signature, secret)
        break
      rescue Stripe::SignatureVerificationError
        next
      end
    end

    return head :bad_request if event.nil?

    case event.type
    when "checkout.session.completed"
      PurchaseFulfillmentService.process_checkout_session(event.data.object)
    end

    head :ok
  rescue JSON::ParserError => e
    Rails.logger.warn("Stripe webhook rejected: #{e.class} #{e.message}")
    head :bad_request
  rescue StandardError => e
    Rails.logger.error("Stripe webhook processing failed: #{e.class} #{e.message}")
    head :unprocessable_entity
  end
end
