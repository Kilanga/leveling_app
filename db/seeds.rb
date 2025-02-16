# Création des catégories
category_fitness = Category.find_or_create_by!(name: "Fitness")
category_meditation = Category.find_or_create_by!(name: "Méditation")
category_coding = Category.find_or_create_by!(name: "Coding")
category_reading = Category.find_or_create_by!(name: "Lecture")
category_nutrition = Category.find_or_create_by!(name: "Nutrition")

# Création du premier utilisateur (utilisateur normal)
user1 = User.create!(
  email: "testuser@example.com",
  password: "password123",
  password_confirmation: "password123",
  confirmed_at: Time.now, # Simule un utilisateur confirmé
  xp: 2500,  # XP global de l'utilisateur
  coins: 500 # Monnaie virtuelle pour les achats en jeu
)

# Création du deuxième utilisateur (admin)
admin_user = User.create!(
  email: "admin@example.com",
  password: "adminpassword",
  password_confirmation: "adminpassword",
  confirmed_at: Time.now, # Simule un compte confirmé
  admin: true,  # Définition du rôle admin
  xp: 5000,  # XP global plus élevé
  coins: 1000 # Plus de monnaie pour tester les achats
)

# Ajout de niveaux pour l'utilisateur normal
UserStat.create!(
  [
    { user: user1, category: category_fitness, level: 6, xp: 1200 },
    { user: user1, category: category_meditation, level: 4, xp: 600 },
    { user: user1, category: category_coding, level: 5, xp: 900 },
    { user: user1, category: category_reading, level: 3, xp: 450 },
    { user: user1, category: category_nutrition, level: 2, xp: 300 }
  ]
)

# Ajout de niveaux pour l'admin (pour tester les fonctionnalités avec un compte avancé)
UserStat.create!(
  [
    { user: admin_user, category: category_fitness, level: 10, xp: 2500 },
    { user: admin_user, category: category_meditation, level: 8, xp: 1800 },
    { user: admin_user, category: category_coding, level: 9, xp: 2200 },
    { user: admin_user, category: category_reading, level: 7, xp: 1400 },
    { user: admin_user, category: category_nutrition, level: 6, xp: 1100 }
  ]
)

# Création de quêtes
quest1 = Quest.create!(
  title: "Courir 5 km",
  description: "Effectuez une course de 5 km d'affilée.",
  xp: 300,
  category: category_fitness,
  valid_until: 1.week.from_now
)

quest2 = Quest.create!(
  title: "Méditer 15 minutes",
  description: "Prenez 15 minutes pour méditer aujourd'hui.",
  xp: 200,
  category: category_meditation,
  valid_until: 1.week.from_now
)

quest3 = Quest.create!(
  title: "Coder une application simple",
  description: "Créez une application avec une interface basique en Vue.js.",
  xp: 500,
  category: category_coding,
  valid_until: 1.week.from_now
)

quest4 = Quest.create!(
  title: "Lire un chapitre d’un livre",
  description: "Prenez 30 minutes pour lire un chapitre d'un livre.",
  xp: 250,
  category: category_reading,
  valid_until: 1.week.from_now
)

quest5 = Quest.create!(
  title: "Manger un repas équilibré",
  description: "Préparez un repas contenant des protéines, des légumes et des glucides sains.",
  xp: 150,
  category: category_nutrition,
  valid_until: 1.week.from_now
)

# Ajout de quêtes accomplies par l'utilisateur normal
UserQuest.create!(
  [
    { user: user1, quest: quest1, progress: 100, completed: true },   # Terminée
    { user: user1, quest: quest2, progress: 100, completed: true },   # Terminée
    { user: user1, quest: quest3, progress: 75, completed: false },   # En cours
    { user: user1, quest: quest4, progress: 100, completed: true },   # Terminée
    { user: user1, quest: quest5, progress: 50, completed: false }    # En cours
  ]
)

# Ajout de quêtes accomplies par l'admin (test avancé)
UserQuest.create!(
  [
    { user: admin_user, quest: quest1, progress: 100, completed: true },   # Terminée
    { user: admin_user, quest: quest2, progress: 100, completed: true },   # Terminée
    { user: admin_user, quest: quest3, progress: 100, completed: true },   # Terminée
    { user: admin_user, quest: quest4, progress: 100, completed: true },   # Terminée
    { user: admin_user, quest: quest5, progress: 100, completed: true }    # Terminée
  ]
)

puts "✅ Seed terminé : deux utilisateurs créés (1 normal, 1 admin) avec niveaux et quêtes !"
