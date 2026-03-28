require "rails_helper"

RSpec.describe "UserQuests", type: :request do
  let(:avatar_url) do
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
  end

  def create_user(index)
    User.create!(
      email: "user_quests_spec_#{index}@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current,
      pseudo: "UserQuestSpec#{index}",
      avatar: avatar_url,
      profile_completed: true
    )
  end

  describe "POST /user_quests" do
    it "does not reactivate a quest completed after the last 22h reset" do
      user = create_user(1)
      category = Category.create!(name: "Spec Daily Lock")
      quest = Quest.create!(title: "Daily Locked Quest", description: "q", xp: 80, category: category)
      last_reset = UserQuest.current_daily_reset_window_start(reference_time: Time.current)
      user_quest = UserQuest.create!(
        user: user,
        quest: quest,
        active: false,
        completed: true,
        progress: 0,
        completed_count: 1,
        updated_at: last_reset + 2.hours
      )

      sign_in user

      post user_quests_path, params: { quest_id: quest.id }

      expect(response).to redirect_to(quests_path)
      expect(flash[:alert]).to include("pas encore disponible")
      expect(user_quest.reload.active).to be(false)
      expect(user_quest.completed).to be(true)
    end

    it "reactivates a quest completed before the last 22h reset" do
      user = create_user(2)
      category = Category.create!(name: "Spec Daily Unlock")
      quest = Quest.create!(title: "Daily Unlock Quest", description: "q", xp: 80, category: category)
      last_reset = UserQuest.current_daily_reset_window_start(reference_time: Time.current)
      user_quest = UserQuest.create!(
        user: user,
        quest: quest,
        active: false,
        completed: true,
        progress: 0,
        completed_count: 1,
        updated_at: last_reset - 1.minute
      )

      sign_in user

      post user_quests_path, params: { quest_id: quest.id }

      expect(response).to redirect_to(quests_path)
      expect(flash[:notice]).to be_present
      expect(user_quest.reload.active).to be(true)
      expect(user_quest.completed).to be(false)
    end
  end
end
