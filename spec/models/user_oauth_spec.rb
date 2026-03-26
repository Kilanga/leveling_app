require "rails_helper"
require "ostruct"

RSpec.describe User, type: :model do
  describe ".from_google_oauth2" do
    let(:auth) do
      OpenStruct.new(
        provider: "google_oauth2",
        uid: "google-uid-123",
        info: OpenStruct.new(
          email: "oauth-user@example.com",
          name: "OAuth User"
        )
      )
    end

    it "creates a confirmed user with generated pseudo and valid default avatar" do
      user = described_class.from_google_oauth2(auth)

      expect(user).to be_persisted
      expect(user.provider).to eq("google_oauth2")
      expect(user.uid).to eq("google-uid-123")
      expect(user.email).to eq("oauth-user@example.com")
      expect(user.pseudo).to be_present
      expect(user.confirmed?).to be(true)
      expect(user.avatar).to be_present
    end

    it "returns existing user for same provider and uid" do
      first_user = described_class.from_google_oauth2(auth)
      second_user = described_class.from_google_oauth2(auth)

      expect(second_user.id).to eq(first_user.id)
    end
  end
end
