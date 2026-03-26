require "rails_helper"

RSpec.describe "Friends", type: :request do
  describe "GET /friends" do
    it "redirects unauthenticated users to sign in" do
      get friends_path

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "POST /friends" do
    it "redirects unauthenticated users to sign in" do
      post friends_path, params: { friend_id: 1 }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
