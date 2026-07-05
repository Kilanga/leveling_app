require "test_helper"
require "ostruct"

class PurchaseFulfillmentServiceTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  def checkout_session(id: "cs_test_1", amount_total: 500, metadata: {})
    OpenStruct.new(id: id, amount_total: amount_total, metadata: metadata.transform_keys(&:to_s))
  end

  test "pack d'orbes : crédite les coins et crée l'achat" do
    session = checkout_session(metadata: { user_id: @user.id, kind: "coins", coins: 120 })

    assert_difference -> { Purchase.count }, 1 do
      PurchaseFulfillmentService.process_checkout_session(session)
    end
    assert_equal 120, @user.reload.coins
    purchase = Purchase.last
    assert_equal "coins", purchase.item_type
    assert_equal "cs_test_1", purchase.transaction_id
    assert_equal 5, purchase.amount
  end

  test "idempotent : le même transaction_id ne crédite pas deux fois" do
    session = checkout_session(metadata: { user_id: @user.id, kind: "coins", coins: 120 })
    PurchaseFulfillmentService.process_checkout_session(session)

    assert_no_difference -> { Purchase.count } do
      PurchaseFulfillmentService.process_checkout_session(session)
    end
    assert_equal 120, @user.reload.coins, "les coins ne doivent pas être doublés"
  end

  test "shop_item : attribue l'objet sans doublon" do
    item = ShopItem.create!(name: "Cadre Test", item_type: "profile_frame", rarity: "rare", description: "Cadre de test")
    session = checkout_session(metadata: { user_id: @user.id, kind: "shop_item", shop_item_id: item.id })

    PurchaseFulfillmentService.process_checkout_session(session)
    assert @user.user_items.exists?(shop_item: item)

    # Rejeu avec un autre id de transaction : pas de doublon d'objet
    session2 = checkout_session(id: "cs_test_2", metadata: { user_id: @user.id, kind: "shop_item", shop_item_id: item.id })
    assert_no_difference -> { @user.user_items.count } do
      PurchaseFulfillmentService.process_checkout_session(session2)
    end
  end

  test "boost : prolonge boost_expires_at depuis le max(actuel, maintenant)" do
    existing = 1.day.from_now
    @user.update!(boost_expires_at: existing)
    session = checkout_session(metadata: { user_id: @user.id, kind: "boost", duration_seconds: 86_400 })

    PurchaseFulfillmentService.process_checkout_session(session)
    assert_in_delta (existing + 1.day).to_i, @user.reload.boost_expires_at.to_i, 2
  end

  test "utilisateur inconnu : aucun achat créé" do
    session = checkout_session(metadata: { user_id: -1, kind: "coins", coins: 120 })
    assert_no_difference -> { Purchase.count } do
      PurchaseFulfillmentService.process_checkout_session(session)
    end
  end

  test "montant de coins invalide : rien ne se passe" do
    session = checkout_session(metadata: { user_id: @user.id, kind: "coins", coins: 0 })
    assert_no_difference -> { Purchase.count } do
      PurchaseFulfillmentService.process_checkout_session(session)
    end
    assert_equal 0, @user.reload.coins
  end
end
