class UserWeeklyQuest < ApplicationRecord
  belongs_to :user
  belongs_to :weekly_quest

  after_update :update_user_stat_xp, if: :saved_change_to_completed?

  private

  # 🔥 Met à jour l'XP de la catégorie associée à la quête
  def update_user_stat_xp
    return unless completed?

    user_stat = UserStat.find_or_create_by(user: user, category: weekly_quest.category)

    # Mise à jour de l'XP
    user_stat.increment!(:xp, weekly_quest.xp_reward)
    user_stat.increment!(:total_xp, weekly_quest.xp_reward) 

    Rails.logger.info "✅ XP mis à jour : #{user_stat.category.name} -> XP: #{user_stat.xp}, Total XP: #{user_stat.total_xp}"
  end
end
