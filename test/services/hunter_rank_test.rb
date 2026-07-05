require "test_helper"

class HunterRankTest < ActiveSupport::TestCase
  test "seuils des rangs" do
    assert_equal "E", HunterRank.for_level(0)[:letter]
    assert_equal "E", HunterRank.for_level(9)[:letter]
    assert_equal "D", HunterRank.for_level(10)[:letter]
    assert_equal "C", HunterRank.for_level(25)[:letter]
    assert_equal "B", HunterRank.for_level(50)[:letter]
    assert_equal "A", HunterRank.for_level(85)[:letter]
    assert_equal "S", HunterRank.for_level(130)[:letter]
    assert_equal "S", HunterRank.for_level(999)[:letter]
  end

  test "progression vers le rang suivant" do
    rank = HunterRank.for_level(5)
    assert_equal "D", rank[:next_letter]
    assert_in_delta 0.5, rank[:progress], 0.001

    max = HunterRank.for_level(200)
    assert_nil max[:next_letter]
    assert_equal 1.0, max[:progress]
  end

  test "for_user somme les niveaux des catégories" do
    user = create(:user)
    cat1 = create(:category, name: "Sport-#{SecureRandom.hex(3)}")
    cat2 = create(:category, name: "Esprit-#{SecureRandom.hex(3)}")
    create(:user_stat, user: user, category: cat1, level: 7)
    create(:user_stat, user: user, category: cat2, level: 6)
    assert_equal "D", HunterRank.for_user(user)[:letter]
  end
end
