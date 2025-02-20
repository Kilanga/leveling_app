require "open-uri"

puts "🔄 Suppression des anciennes données..."

# 🔥 Supprimer les relations dépendantes AVANT les entités principales
UserWeeklyQuest.destroy_all
WeeklyQuest.destroy_all   # Ajout de cette ligne pour éviter l'erreur
UserQuest.destroy_all
UserStat.destroy_all
UserBadge.destroy_all
Friendship.destroy_all

# 🔥 Ensuite, supprimer les entités principales
User.destroy_all
Quest.destroy_all
Category.destroy_all
Badge.destroy_all



BADGES = [
  { name: "Débutant", description: "A complété 10 quêtes", image_url: "https://res.cloudinary.com/dqpfnffmi/image/upload/v1740071281/D%C3%A9butant-removebg-preview_1_xhmriw.png" },
  { name: "Aventurier", description: "A complété 50 quêtes", image_url: "https://res.cloudinary.com/dqpfnffmi/image/upload/v1740071281/Aventurier-removebg-preview_i7jmlj.png" },
  { name: "Expert", description: "A complété 100 quêtes", image_url: "https://res.cloudinary.com/dqpfnffmi/image/upload/v1740071281/Expert-removebg-preview_v6u6uk.png" },
  { name: "Maître", description: "A complété 500 quêtes", image_url: "https://res.cloudinary.com/dqpfnffmi/image/upload/v1740071281/Maitre-removebg-preview_dlncnk.png" },
  { name: "Conquérant", description: "A complété 1000 quêtes", image_url: "https://res.cloudinary.com/dqpfnffmi/image/upload/v1740071280/conquerant-removebg-preview_s1h57m.png" },
  { name: "Maître de la Discipline", description: "A atteint 5000 XP en Discipline", image_url: "https://res.cloudinary.com/dqpfnffmi/image/upload/v1740071280/Discipline-removebg-preview_ncxv0u.png" },
  { name: "Athlète Élite", description: "A atteint 5000 XP en Physique", image_url: "https://res.cloudinary.com/dqpfnffmi/image/upload/v1740071280/Athlete-removebg-preview_1_dtu24h.png" },
  { name: "Erudit Suprême", description: "A atteint 5000 XP en Savoir", image_url: "https://res.cloudinary.com/dqpfnffmi/image/upload/v1740071280/Erudit-removebg-preview_ytsdlv.png" },
  { name: "Charisme Légendaire", description: "A atteint 5000 XP en Social", image_url: "https://res.cloudinary.com/dqpfnffmi/image/upload/v1740071280/charisme-removebg-preview_rywu4u.png" },
  { name: "Maître des Défis", description: "A atteint 5000 XP en Défi", image_url: "https://res.cloudinary.com/dqpfnffmi/image/upload/v1740071280/defi-removebg-preview_1_gamk3u.png" },
  { name: "Légende", description: "A terminé toutes les quêtes du jeu au moins une fois", image_url: "https://res.cloudinary.com/dqpfnffmi/image/upload/v1740071279/legende-removebg-preview_vwpdqr.png" }
]


BADGES.each do |badge_data|
  badge = Badge.find_or_create_by!(name: badge_data[:name]) do |b|
    b.description = badge_data[:description]
  end

  # 🔥 Attache l'image depuis Cloudinary uniquement si elle n'est pas déjà attachée
  unless badge.image.attached?
    file = URI.open(badge_data[:image_url])
    badge.image.attach(io: file, filename: "#{badge.name.downcase.gsub(" ", "_")}.png", content_type: "image/png")
  end
end

# 📌 Création des catégories
puts "🔄 Création des catégories..."
categories = {
  discipline: Category.find_or_create_by!(name: "Discipline"),
  physique: Category.find_or_create_by!(name: "Physique"),
  savoir: Category.find_or_create_by!(name: "Savoir"),
  social: Category.find_or_create_by!(name: "Social"),
  defi: Category.find_or_create_by!(name: "Défi")
}

# 📌 Création des utilisateurs
puts "🔄 Création des utilisateurs..."
user1 = User.create!(
  email: "testuser@example.com",
  password: "password123",
  password_confirmation: "password123",
  confirmed_at: Time.now,
  xp: 0,
  coins: 500,
  pseudo: "TestUser",
  avatar: "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
)

admin_user = User.create!(
  email: "admin@example.com",
  password: "adminpassword",
  password_confirmation: "adminpassword",
  confirmed_at: Time.now,
  admin: true,
  xp: 0,
  coins: 1000,
  pseudo: "AdminUser",
  avatar: "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
)

# 📌 Création des quêtes
puts "🔄 Création des quêtes..."
quests = [
  { title: "Compléter un exercice de concentration", xp: 300, category: categories[:discipline] },
  { title: "Faire une séance de sport intense", xp: 500, category: categories[:physique] },
  { title: "Lire un livre de développement personnel", xp: 250, category: categories[:savoir] },
  { title: "Organiser un événement social", xp: 400, category: categories[:social] },
  { title: "Relever un défi en dehors de sa zone de confort", xp: 600, category: categories[:defi] }
]

quests.each do |q|
  Quest.find_or_create_by!(title: q[:title]) do |quest|
    quest.description = "Accomplir cette tâche pour gagner de l'XP."
    quest.xp = q[:xp]
    quest.category = q[:category]
    quest.valid_until = 1.week.from_now
  end
end

# 📌 Associer des quêtes accomplies aux utilisateurs
puts "🔄 Attribution des quêtes aux utilisateurs..."
completed_quests = {
  user1 => ["Compléter un exercice de concentration", "Lire un livre de développement personnel"],
  admin_user => ["Faire une séance de sport intense", "Organiser un événement social", "Relever un défi en dehors de sa zone de confort"]
}

completed_quests.each do |user, quest_titles|
  quest_titles.each do |title|
    quest = Quest.find_by(title: title)
    UserQuest.create!(user: user, quest: quest, progress: 100, completed: true, completed_count: 1) if quest
  end
end

# 📌 Mise à jour des stats utilisateur
puts "🔄 Mise à jour des statistiques des utilisateurs..."
[user1, admin_user].each do |user|
  categories.each do |_, category|
    xp_gained = user.user_quests.joins(:quest).where(quests: { category_id: category.id }, completed: true).sum(:xp)
    if xp_gained > 0
      UserStat.create!(
        user: user,
        category: category,
        level: 1,
        xp: xp_gained,
        total_xp: xp_gained
      )
    end
  end
end

puts "🎉 ✅ Seed terminée avec succès !"
