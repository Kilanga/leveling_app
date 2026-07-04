require "application_system_test_case"

class PurchaseTest < ApplicationSystemTestCase
  def setup
    @user = create(:user)
    sign_in @user
  end

  test "l'utilisateur voit la boutique et ses soldes" do
    visit new_purchase_path

    assert_text I18n.t("purchases.new.page_title")
    assert_text "Orbes"
    assert_text "Fragments"
  end
end
