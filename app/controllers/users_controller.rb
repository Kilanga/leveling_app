class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @user_quests = @user.user_quests.where("completed_count > 0").includes(:quest).order(completed_count: :desc)
    @user_badges = @user.user_badges.includes(:badge).order(awarded_at: :desc)
  end

  def update
    puts "🛠️ Entrée dans update pour user_quest #{params[:id]}"
    @user_quest = current_user.user_quests.find(params[:id])
  
    if @user_quest.completed
      redirect_to dashboard_path, alert: "Tu as déjà terminé cette quête."
    else
      @user_quest.increment!(:completed_count) # 🔥 Incrémente le compteur de complétion
      @user_quest.update!(completed: true)
      current_user.increment!(:xp, @user_quest.quest.xp)
  
      puts "🚀 Appel de check_and_award_badges pour #{current_user.pseudo}"
      check_and_award_badges(current_user)
  
      redirect_to dashboard_path, notice: "Quête validée, XP ajouté !"
    end
  end
  

  private

  def check_and_award_badges(user)
    total_quests_completed = user.user_quests.sum(:completed_count)
    puts "📊 Total de quêtes complétées pour #{user.pseudo} : #{total_quests_completed}"

    award_badge(user, "Débutant") if total_quests_completed >= 10
    award_badge(user, "Aventurier") if total_quests_completed >= 50
    award_badge(user, "Expert") if total_quests_completed >= 100
    award_badge(user, "Maître") if total_quests_completed >= 500
    award_badge(user, "Conquérant") if total_quests_completed >= 1000
  
    user.user_stats.each do |stat|
      if stat.category.name == "Discipline" && stat.xp >= 5000
        award_badge(user, "Maître de la Discipline")
      elsif stat.category.name == "Physique" && stat.xp >= 5000
        award_badge(user, "Athlète Élite")
      elsif stat.category.name == "Savoir" && stat.xp >= 5000
        award_badge(user, "Erudit Suprême")
      elsif stat.category.name == "Social" && stat.xp >= 5000
        award_badge(user, "Charisme Légendaire")
      elsif stat.category.name == "Défi" && stat.xp >= 5000
        award_badge(user, "Maître des Défis")
      end
    end
  
    if user.user_weekly_quests.where(completed: true)
      .where("created_at >= ?", 7.days.ago)
      .count >= 5
award_badge(user, "Champion Hebdomadaire")
end

  
    if total_quests_completed >= Quest.count
      award_badge(user, "Légende")
    end
  end
  
  def award_badge(user, badge_name)
    badge = Badge.find_by(name: badge_name)
    return if badge.nil? || user.user_badges.exists?(badge_id: badge.id)
  
    user.user_badges.create!(badge: badge, awarded_at: Time.current)
  end
end  