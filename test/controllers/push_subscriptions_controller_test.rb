class PushSubscriptionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user)
    sign_in @user
  end

  test "crée un abonnement push" do
    assert_difference -> { PushSubscription.count }, 1 do
      post push_subscriptions_url, params: { push_subscription: {
        endpoint: "https://push.example.com/sub/1", p256dh_key: "p256", auth_key: "auth"
      } }
    end
    assert_response :created
    assert_equal @user, PushSubscription.last.user
  end

  test "réutilise l'endpoint existant sans doublon" do
    2.times do
      post push_subscriptions_url, params: { push_subscription: {
        endpoint: "https://push.example.com/sub/1", p256dh_key: "p256", auth_key: "auth"
      } }
    end
    assert_equal 1, PushSubscription.where(endpoint: "https://push.example.com/sub/1").count
  end

  test "supprime par endpoint" do
    @user.push_subscriptions.create!(endpoint: "https://push.example.com/sub/2", p256dh_key: "p", auth_key: "a")
    assert_difference -> { PushSubscription.count }, -1 do
      delete push_subscriptions_url, params: { endpoint: "https://push.example.com/sub/2" }
    end
  end
end
