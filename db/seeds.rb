require "open-uri"
require "faker"

puts "🔄 Suppression des anciennes données..."

# 🔥 Supprimer les relations dépendantes AVANT les entités principales
UserWeeklyQuest.destroy_all
WeeklyQuest.destroy_all
UserQuest.destroy_all
UserStat.destroy_all
UserBadge.destroy_all
UserItem.destroy_all
Friendship.destroy_all

# 🔥 Ensuite, supprimer les entités principales
User.destroy_all
Quest.destroy_all
Category.destroy_all
Badge.destroy_all
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
  { name: "Héros Local", item_type: "title", rarity: "rare", price_coins: 150 },
  { name: "Champion Réputé", item_type: "title", rarity: "epic", price_coins: 600 },
  { name: "Légende Vivante", item_type: "title", rarity: "legendary", price_coins: 1200 }
]

titles.each do |title|
  item = ShopItem.find_or_create_by!(name: title[:name]) do |shop_item|
    shop_item.item_type = title[:item_type]
    shop_item.rarity = title[:rarity]
    shop_item.price_coins = title[:price_coins]
    shop_item.description = "Un titre prestigieux affiché sur votre profil."
  end

  # 📌 Attache une image depuis Cloudinary
  unless item.image.attached?
    file = URI.open("https://res.cloudinary.com/dqpfnffmi/image/upload/v1728248261/image-cake-thumbnail_wwxfii.jpg")
    item.image.attach(io: file, filename: "#{item.name.parameterize}.jpg", content_type: "image/jpeg")
    item.save!
  end
end

# 📌 **Attribution d’un titre légendaire à AdminUser**
legendary_title = ShopItem.find_by(name: "Légende Vivante")
admin_user.activate_title(legendary_title)

# 📌 **Activation d’un Boost XP pour AdminUser (durée : 1 semaine)**
admin_user.update!(boost_expires_at: 7.days.from_now)

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
  user1 => [ "Compléter un exercice de concentration", "Lire un livre de développement personnel" ],
  admin_user => [ "Faire une séance de sport intense", "Organiser un événement social", "Relever un défi en dehors de sa zone de confort" ]
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
