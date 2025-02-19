# Création des catégories
categories = {
  fitness: Category.find_or_create_by!(name: "Fitness"),
  meditation: Category.find_or_create_by!(name: "Méditation"),
  coding: Category.find_or_create_by!(name: "Coding"),
  reading: Category.find_or_create_by!(name: "Lecture"),
  nutrition: Category.find_or_create_by!(name: "Nutrition")
}

# Création des utilisateurs
user1 = User.create!(
  email: "testuser@example.com",
  password: "password123",
  password_confirmation: "password123",
  confirmed_at: Time.now,
  xp: 0,
  coins: 500,
  pseudo: "TestUser",
  avatar: "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.50_-_A_digital_painting_of_a_female_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._She_wears_a_simple_slightly_x4zdiw.webp"
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
  avatar: "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.50_-_A_digital_painting_of_a_female_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._She_wears_a_simple_slightly_x4zdiw.webp"
)

# Création des quêtes
quests = [
  { title: "Courir 5 km", xp: 300, category: categories[:fitness] },
  { title: "Méditer 15 minutes", xp: 200, category: categories[:meditation] },
  { title: "Coder une application simple", xp: 500, category: categories[:coding] },
  { title: "Lire un chapitre d’un livre", xp: 250, category: categories[:reading] },
  { title: "Manger un repas équilibré", xp: 150, category: categories[:nutrition] }
]

quests.each do |q|
  Quest.find_or_create_by!(title: q[:title]) do |quest|
    quest.description = "Accomplir la tâche"
    quest.xp = q[:xp]
    quest.category = q[:category]
    quest.valid_until = 1.week.from_now
  end
end

# Associer les quêtes accomplies aux utilisateurs
completed_quests = {
  user1 => [ "Courir 5 km", "Méditer 15 minutes", "Lire un chapitre d’un livre" ],
  admin_user => [ "Courir 5 km", "Méditer 15 minutes", "Coder une application simple", "Lire un chapitre d’un livre", "Manger un repas équilibré" ]
}

completed_quests.each do |user, quest_titles|
  quest_titles.each do |title|
    quest = Quest.find_by(title: title)
    UserQuest.create!(user: user, quest: quest, progress: 100, completed: true) if quest
  end
end

# Mise à jour des stats utilisateur
[ user1, admin_user ].each do |user|
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

puts "✅ Seed mise à jour et adaptée au schéma actuel !"
