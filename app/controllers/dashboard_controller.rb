class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @weekly_quests = current_user.user_weekly_quests
  .joins(:weekly_quest)  # Assure la jointure avec weekly_quests
  .where("weekly_quests.valid_until >= ?", Time.current)
  .includes(:weekly_quest)  # Charge les quêtes pour éviter le N+1

    @user_quests = current_user.user_quests.includes(:quest)
    @stats = current_user.user_stats.includes(:category)
    Rails.logger.info "📊 Vérification XP: User XP = #{current_user.xp}, UserStats = #{@stats.map { |s| "#{s.category.name}: #{s.xp}" }.join(", ")}"
    # 🔥 Synchronisation des niveaux et XP
    @stats.each do |stat|
      recalculated_level, recalculated_xp = calculate_level_and_xp(stat.total_xp)

      # Mise à jour en base de données si nécessaire
      if stat.level != recalculated_level || stat.xp != recalculated_xp
        stat.update(level: recalculated_level, xp: recalculated_xp)
      end
    end
    puts "🚀 Vérification des badges pour #{current_user.pseudo}"
    check_and_award_badges(current_user)
    # 🔥 Préparer les données pour le Radar Chart
    @stats_data = @stats.map do |stat|
      {
        name: stat.category.name,
        level: stat.level,
        xp: stat.xp,
        xp_needed: xp_needed_for_next_level(stat.level)
      }
    end

    @total_level = @stats.sum(&:level)

    # 🔥 Répondre avec JSON si format JSON demandé
    respond_to do |format|
      format.html # Rendu normal en HTML
      format.json { render json: @stats_data } # 🔥 JSON pour le Radar Chart
    end
  end

  private

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
    if stat.category.name == "Discipline" && stat.total_xp >= 5000
      award_badge(user, "Maître de la Discipline")
    elsif stat.category.name == "Physique" && stat.total_xp >= 5000
      award_badge(user, "Athlète Élite")
    elsif stat.category.name == "Savoir" && stat.total_xp >= 5000
      award_badge(user, "Erudit Suprême")
    elsif stat.category.name == "Social" && stat.total_xp >= 5000
      award_badge(user, "Charisme Légendaire")
    elsif stat.category.name == "Défi" && stat.total_xp >= 5000
      award_badge(user, "Maître des Défis")
    end
  end

  if user.user_weekly_quests.where(completed: true)
                            .where("created_at >= ?", 7.days.ago)
                            .count >= 5
    award_badge(user, "Champion Hebdomadaire")
  end

  all_quests_completed = Quest.all.all? do |quest|
    user.user_quests.where(quest: quest).sum(:completed_count) >= 1
  end

  if all_quests_completed
    award_badge(user, "Légende")
  end
end

def award_badge(user, badge_name)
  badge = Badge.find_by(name: badge_name)
  return if badge.nil? || user.user_badges.exists?(badge_id: badge.id)

  puts "🏆 Attribution du badge : #{badge_name} à #{user.pseudo}"
  user.user_badges.create!(badge: badge, awarded_at: Time.current)
end


  # 🔥 Fonction pour calculer le niveau et l'XP restant
  def calculate_level_and_xp(total_xp)
    level = 1
    xp_remaining = total_xp
    xp_needed_for_next = xp_needed_for_next_level(level)

    while xp_remaining >= xp_needed_for_next
      xp_remaining -= xp_needed_for_next
      level += 1
      xp_needed_for_next = xp_needed_for_next_level(level)
    end

    [ level, xp_remaining ]
  end

  # 🔥 XP nécessaire pour le niveau suivant
  def xp_needed_for_next_level(level)
    case level
    when 1..10
      level * 100
    when 11..20
      (level**1.8 * 100).to_i
    when 21..30
      (level**1.7 * 100).to_i
    when 31..40
      (level**1.6 * 100).to_i
    when 41..50
      (level**1.5 * 100).to_i
    when 51..60
      (level**1.4 * 100).to_i
    when 61..70
      (level**1.3 * 100).to_i
    when 71..80
      (level**1.2 * 100).to_i
    when 81..90
      (level**1.1 * 100).to_i
    else
      (level**1.1 * 100).to_i # Niveau 91+
    end
  end
end
