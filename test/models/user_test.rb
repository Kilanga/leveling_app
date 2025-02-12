require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.create(email: "test@example.com", password: "password")
    @category = Category.create(name: "Intelligence")
  end

  test "ajoute de l'XP correctement" do
    stat = @user.user_stats.create(category: @category, level: 1, xp: 0)
    stat.update(xp: stat.xp + 100)
    assert_equal 100, stat.reload.xp
  end
end
