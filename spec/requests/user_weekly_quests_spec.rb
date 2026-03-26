require "rails_helper"

RSpec.describe "UserWeeklyQuests", type: :request do
  let(:avatar_url) do
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
  end

  describe "PATCH /user_weekly_quests/:id" do
    it "marks weekly quest as completed and redirects" do
      user = User.create!(
        email: "weekly_spec@example.com",
        password: "password123",
        password_confirmation: "password123",
        confirmed_at: Time.current,
        pseudo: "WeeklySpec",
        avatar: avatar_url,
        profile_completed: true
      )
      category = Category.create!(name: "Spec Weekly")
      weekly_quest = WeeklyQuest.create!(
        title: "Weekly Spec Quest",
        description: "Quest de test",
        xp_reward: 300,
        category: category,
        valid_until: 7.days.from_now
      )
      user_weekly_quest = UserWeeklyQuest.create!(
        user: user,
        weekly_quest: weekly_quest,
        completed: false
      )

      sign_in user

      patch user_weekly_quest_path(user_weekly_quest), params: { action_type: "complete" }

      expect(response).to redirect_to(dashboard_path)
      expect(user_weekly_quest.reload.completed).to be(true)
    end
  end
end
