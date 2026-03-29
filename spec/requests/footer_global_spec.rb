require 'rails_helper'

describe "Footer global", type: :request do
  it "est présent sur la page d'accueil" do
    get root_path
    expect(response.body).to include("footer-global")
    expect(response.body).to include("href=\"/terms\"")
    expect(response.body).to include("href=\"/privacy\"")
  end

  it "est présent sur la page dashboard si connecté" do
    user = User.first || FactoryBot.create(:user)
    sign_in user
    get dashboard_path
    expect(response.body).to include("footer-global")
    expect(response.body).to include("href=\"/terms\"")
    expect(response.body).to include("href=\"/privacy\"")
  end
end
