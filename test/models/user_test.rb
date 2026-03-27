require "test_helper"

class UserTest < ActiveSupport::TestCase
  VALID_AVATAR = "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"

  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password",
      pseudo: "hunter_test",
      avatar: VALID_AVATAR,
      confirmed_at: Time.current
    )
    @category = Category.create!(name: "Intelligence_#{SecureRandom.hex(4)}")
  end

  test "ajoute de l'XP correctement" do
    stat = UserStat.create!(user: @user, category: @category, level: 1, xp: 0, total_xp: 0)
    stat.update(xp: stat.xp + 100)
    assert_equal 100, stat.reload.xp
  end
end
