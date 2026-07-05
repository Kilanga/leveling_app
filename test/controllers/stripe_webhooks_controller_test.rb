require "test_helper"
require "ostruct"
require "minitest/mock"

class StripeWebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    # S'assure qu'un secret webhook est présent pour le test
    Rails.configuration.stripe[:webhook_secrets] = [ "whsec_test" ]
  end

  test "signature invalide -> bad_request" do
    post stripe_webhook_url, params: "{}", headers: { "Stripe-Signature" => "invalid", "CONTENT_TYPE" => "application/json" }
    assert_response :bad_request
  end

  test "checkout.session.completed valide -> traite l'achat" do
    session = OpenStruct.new(
      id: "cs_test_webhook",
      amount_total: 500,
      metadata: { "user_id" => @user.id, "kind" => "coins", "coins" => "120" }
    )
    event = OpenStruct.new(type: "checkout.session.completed", data: OpenStruct.new(object: session))

    Stripe::Webhook.stub(:construct_event, event) do
      assert_difference -> { Purchase.count }, 1 do
        post stripe_webhook_url, params: "{}", headers: { "Stripe-Signature" => "any", "CONTENT_TYPE" => "application/json" }
      end
    end
    assert_response :ok
    assert_equal 120, @user.reload.coins
  end

  test "type d'événement inconnu -> ok sans effet" do
    event = OpenStruct.new(type: "invoice.paid", data: OpenStruct.new(object: nil))
    Stripe::Webhook.stub(:construct_event, event) do
      assert_no_difference -> { Purchase.count } do
        post stripe_webhook_url, params: "{}", headers: { "Stripe-Signature" => "any", "CONTENT_TYPE" => "application/json" }
      end
    end
    assert_response :ok
  end
end
