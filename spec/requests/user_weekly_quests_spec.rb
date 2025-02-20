require 'rails_helper'

RSpec.describe "UserWeeklyQuests", type: :request do
  describe "GET /update" do
    it "returns http success" do
      get "/user_weekly_quests/update"
      expect(response).to have_http_status(:success)
    end
  end

end
