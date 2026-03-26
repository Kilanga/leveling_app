require "rails_helper"

RSpec.describe ShopItem, type: :model do
  it "is valid with required attributes" do
    item = described_class.new(
      name: "Titre Test",
      description: "Objet de test",
      item_type: "title",
      rarity: "rare",
      price_coins: 100
    )

    expect(item).to be_valid
  end

  it "is invalid with unsupported rarity" do
    item = described_class.new(
      name: "Objet Invalide",
      description: "Objet de test",
      item_type: "title",
      rarity: "common"
    )

    expect(item).not_to be_valid
  end
end
