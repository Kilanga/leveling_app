require "application_system_test_case"

class PurchaseTest < ApplicationSystemTestCase
  def setup
    @user = create(:user)
    sign_in @user
  end

  test "l'utilisateur voit la boutique et ses soldes" do
    visit new_purchase_path

    # Le titre est affiché en majuscules par le CSS -> comparaison insensible à la casse
    assert_text(/#{Regexp.escape(I18n.t("purchases.new.page_title"))}/i)
    assert_text "Orbes"
    assert_text "Fragments"
  end
end
