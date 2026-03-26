require "rails_helper"

RSpec.describe Badge, type: :model do
  it "is valid with required attributes" do
    badge = described_class.new(name: "Conquerant", description: "Badge de test")
    expect(badge).to be_valid
  end

  it "is invalid without a name" do
    badge = described_class.new(description: "Badge de test")
    expect(badge).not_to be_valid
  end
end
