require "application_system_test_case"

class PurchaseTest < ApplicationSystemTestCase
  def setup
    @user = User.create(email: "test@example.com", password: "password")
    sign_in @user
  end

  test "L'utilisateur achète 100 pièces" do
    visit new_purchase_path
    click_button "100 pièces - 5€"

    assert_text "Achat réussi !"
    assert_equal 100, @user.reload.coins
  end
end
