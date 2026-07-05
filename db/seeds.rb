require "open-uri"

puts "🔄 Suppression des anciennes données..."

# 🔥 Supprimer les relations dépendantes AVANT les entités principales
UserWeeklyQuest.destroy_all
WeeklyQuest.destroy_all
UserQuest.destroy_all
UserStat.destroy_all
UserItem.destroy_all
Friendship.destroy_all

# 🔥 Ensuite, supprimer les entités principales
User.destroy_all
Quest.destroy_all
Category.destroy_all
ShopItem.destroy_all

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

# 📌 **Création des titres disponibles à l'achat**
puts "🔄 Création des titres en boutique..."
titles = [
  {
    name: "Héros Local",
    item_type: "title",
    rarity: "rare",
    price_coins: 150,
    description: "Connu de tous, tu fais le travail proprement."
  },
  {
    name: "Sentinelle d'Aube",
    item_type: "title",
    rarity: "rare",
    price_coins: 220,
    description: "Toujours premier connecte, toujours deja en action."
  },
  {
    name: "Briseur d'Inertie",
    item_type: "title",
    rarity: "rare",
    price_coins: 280,
    description: "Tu lances les taches difficiles sans attendre."
  },
  {
    name: "Champion Réputé",
    item_type: "title",
    rarity: "epic",
    price_coins: 600,
    description: "Ton niveau est reconnu par tout le serveur."
  },
  {
    name: "Architecte du Tempo",
    item_type: "title",
    rarity: "epic",
    price_coins: 720,
    description: "Tu gardes un rythme fort sans t'effondrer."
  },
  {
    name: "Maitrise Fractale",
    item_type: "title",
    rarity: "epic",
    price_coins: 880,
    description: "Chaque petit gain chez toi compte double."
  },
  {
    name: "Légende Vivante",
    item_type: "title",
    rarity: "legendary",
    price_coins: 1200,
    description: "Ton profil est devenu une reference du classement."
  },
  {
    name: "Souverain des Paliers",
    item_type: "title",
    rarity: "legendary",
    price_coins: 1450,
    description: "Tu valides les paliers que les autres visent encore."
  },
  {
    name: "Etoile de la Derniere Quete",
    item_type: "title",
    rarity: "legendary",
    price_coins: 1650,
    description: "Tu finis fort, meme quand tout le monde ralentit."
  }
]

titles.each do |title|
  item = ShopItem.find_or_initialize_by(name: title[:name])
  item.item_type = title[:item_type]
  item.rarity = title[:rarity]
  item.price_coins = title[:price_coins]
  item.price_euros = nil
  item.description = title[:description]
  item.save!

  # 📌 Attache une image depuis Cloudinary
  unless item.image.attached?
    begin
      file = URI.open("https://res.cloudinary.com/dqpfnffmi/image/upload/v1728248261/image-cake-thumbnail_wwxfii.jpg", read_timeout: 5)
      item.image.attach(io: file, filename: "#{item.name.parameterize}.jpg", content_type: "image/jpeg")
      item.save!
    rescue StandardError => e
      puts "⚠️ Erreur lors du téléchargement de l'image pour #{item.name}: #{e.message}"
    end
  end
end

# 📌 **Création des titres libres débloquables par achievements**
puts "🔄 Création des titres libres..."
free_titles = [
  { name: "Eclaireur", rarity: "common", description: "Tu as fait tes premiers pas d'aventurier." },
  { name: "Regulier", rarity: "common", description: "Ta constance commence a se voir." },
  { name: "Polyvalent", rarity: "common", description: "Tu progresses sur plusieurs fronts." },
  { name: "Cadence Hebdo", rarity: "common", description: "Ton rythme hebdomadaire est solide." },
  { name: "Stratege Patient", rarity: "rare", description: "Tu construis ta progression avec discipline." },
  { name: "Architecte du Progres", rarity: "epic", description: "Tu maitrises un large spectre de missions." },
  { name: "Ascension Totale", rarity: "legendary", description: "Tu incarnes l'excellence globale du jeu." }
]

free_titles.each do |title_data|
  item = ShopItem.find_or_create_by!(name: title_data[:name]) do |shop_item|
    shop_item.item_type = "title"
    shop_item.rarity = title_data[:rarity]
    shop_item.price_coins = nil
    shop_item.price_euros = nil
    shop_item.description = title_data[:description]
  end

  unless item.image.attached?
    begin
      file = URI.open("https://res.cloudinary.com/dqpfnffmi/image/upload/v1728248261/image-cake-thumbnail_wwxfii.jpg", read_timeout: 5)
      item.image.attach(io: file, filename: "#{item.name.parameterize}.jpg", content_type: "image/jpeg")
      item.save!
    rescue StandardError => e
      puts "⚠️ Erreur lors du téléchargement de l'image pour #{item.name}: #{e.message}"
    end
  end
end
legendary_title = ShopItem.find_by(name: "Légende Vivante")
admin_user.activate_title(legendary_title)

# 📌 **Activation d’un Boost XP pour AdminUser (durée : 1 semaine)**
admin_user.update!(boost_expires_at: 7.days.from_now)

# 📌 Création des quêtes
puts "🔄 Création des quêtes..."
# Catalogue V2 (ton Solo Leveling, difficulté E→S, XP rééquilibré).
# Source de vérité : app/services/quest_catalog.rb
QuestCatalog.sync!

# 📌 Associer des quêtes accomplies aux utilisateurs
puts "🔄 Attribution des quêtes aux utilisateurs..."
completed_quests = {
  user1 => [ "Œil du chasseur : 10 minutes de focus absolu", "Grimoire de croissance : 20 pages annotées" ],
  admin_user => [ "Raid complet : séance de sport intense", "Rassemblement de guilde : un événement organisé", "Sortie de la zone sûre : un défi hors de ta zone de confort" ]
}

completed_quests.each do |user, quest_titles|
  quest_titles.each do |title|
    quest = Quest.find_by(title: title)
    UserQuest.create!(user: user, quest: quest, progress: 100, completed: true, completed_count: 1) if quest
  end
end

# 📌 Mise à jour des stats utilisateur
puts "🔄 Mise à jour des statistiques des utilisateurs..."
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

puts "🎉 ✅ Seed terminée avec succès !"
