require "test_helper"

class RackAttackTest < ActionDispatch::IntegrationTest
  setup do
    Rack::Attack.enabled = true
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  teardown do
    Rack::Attack.enabled = false
  end

  test "bloque la 6e tentative de connexion depuis la même IP" do
    5.times do
      post user_session_path, params: { user: { email: "a@b.fr", password: "x" } }
      assert_not_equal 429, response.status
    end
    post user_session_path, params: { user: { email: "a@b.fr", password: "x" } }
    assert_equal 429, response.status
  end
end
