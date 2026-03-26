require "open-uri"
require "faker"

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
  { name: "Voyageur", rarity: "common", description: "Premier titre débloqué: tu as entamé ton voyage." },
  { name: "Persévérant", rarity: "common", description: "Tu as complété 10 quêtes, ta détermination inspire." },
  { name: "Combattant", rarity: "common", description: "50 quêtes complétées, tu es un guerrier redoutable." },
  { name: "Vétéran", rarity: "common", description: "200 quêtes, tu es devenu une légende." }
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
quest_catalog = {
  discipline: [
    { title: "Compléter un exercice de concentration", description: "10 minutes sans distraction sur une seule tâche.", xp: 300 },
    { title: "Planifier la journée en 5 priorités", description: "Définir un plan clair et réaliste pour la journée.", xp: 180 },
    { title: "Se lever sans snooze", description: "Sortir du lit dès la première alarme.", xp: 140 },
    { title: "Tenir un journal d'habitudes", description: "Suivre ses habitudes quotidiennes pendant la journée.", xp: 200 },
    { title: "Bloquer 1h de travail profond", description: "Travailler sans notification ni interruption.", xp: 260 },
    { title: "Ranger son espace de travail", description: "Créer un environnement propre et propice à la concentration.", xp: 120 },
    { title: "Respecter sa routine matinale", description: "Suivre sa routine sans sauter d'étape.", xp: 170 },
    { title: "Éteindre les écrans avant minuit", description: "Stopper les écrans 30 minutes avant le coucher.", xp: 150 },
    { title: "Préparer ses tâches du lendemain", description: "Lister les missions prioritaires du lendemain.", xp: 160 },
    { title: "Terminer une tâche commencée", description: "Finaliser une tâche en cours sans la repousser.", xp: 190 },
    { title: "Faire une pause consciente", description: "Prendre 10 minutes de pause sans téléphone.", xp: 110 },
    { title: "Réviser ses objectifs hebdomadaires", description: "Mettre à jour et clarifier ses objectifs de la semaine.", xp: 210 },
    { title: "Supprimer 20 distractions numériques", description: "Nettoyer les onglets, notifications et apps inutiles.", xp: 220 },
    { title: "Travailler en mode Pomodoro x4", description: "Enchaîner 4 cycles focus/pause complets.", xp: 280 },
    { title: "Finir une tâche difficile en premier", description: "Appliquer la règle du 'eat the frog'.", xp: 240 },
    { title: "Respecter une heure de coucher fixe", description: "Se coucher dans un créneau constant.", xp: 170 },
    { title: "Faire un bilan de fin de journée", description: "Analyser ce qui a été fait et ce qui bloque.", xp: 160 },
    { title: "Ne pas procrastiner sur une tâche clé", description: "Passer à l'action immédiatement sur la priorité n°1.", xp: 230 },
    { title: "Limiter les réseaux à 20 minutes", description: "Respecter une limite stricte d'usage social.", xp: 180 },
    { title: "Maintenir 3 jours de routine", description: "Conserver sa discipline sans rupture pendant 3 jours.", xp: 320 }
  ],
  physique: [
    { title: "Faire une séance de sport intense", description: "Séance complète avec échauffement et retour au calme.", xp: 500 },
    { title: "Faire 30 minutes de cardio", description: "Courir, vélo ou corde à sauter sans interruption.", xp: 250 },
    { title: "Atteindre 10 000 pas", description: "Bouger activement sur la journée.", xp: 180 },
    { title: "Réaliser une séance de mobilité", description: "Travail des articulations et amplitude de mouvement.", xp: 170 },
    { title: "Faire 50 pompes cumulées", description: "Répartir sur la journée si nécessaire.", xp: 220 },
    { title: "Tenir 5 minutes de gainage", description: "Cumuler des planches de qualité.", xp: 200 },
    { title: "Faire une sortie à vélo", description: "Sortie d'au moins 45 minutes.", xp: 230 },
    { title: "S'hydrater correctement", description: "Atteindre son objectif d'hydratation quotidien.", xp: 120 },
    { title: "S'étirer 15 minutes", description: "Routine complète haut et bas du corps.", xp: 130 },
    { title: "Monter les escaliers 20 fois", description: "Remplacer l'ascenseur par des escaliers.", xp: 190 },
    { title: "Faire un entraînement HIIT", description: "Séance fractionnée de 20 minutes minimum.", xp: 300 },
    { title: "Courir 5 km", description: "Gérer allure et respiration sur la distance.", xp: 320 },
    { title: "Faire une séance jambes", description: "Squats, fentes et renforcement ciblé.", xp: 260 },
    { title: "Faire une séance haut du corps", description: "Dos, épaules, pectoraux et bras.", xp: 260 },
    { title: "Récupération active", description: "Marche et mobilité légère pour relancer la circulation.", xp: 140 },
    { title: "Tenir une posture correcte toute la journée", description: "Vigilance continue sur l'alignement corporel.", xp: 150 },
    { title: "Faire 100 squats cumulés", description: "Objectif volume jambes sur la journée.", xp: 260 },
    { title: "Faire 60 minutes de marche rapide", description: "Allure soutenue et régulière.", xp: 210 },
    { title: "Dormir au moins 8 heures", description: "Optimiser la récupération physique.", xp: 200 },
    { title: "Enchaîner 4 entraînements dans la semaine", description: "Régularité sportive sur plusieurs jours.", xp: 380 }
  ],
  savoir: [
    { title: "Lire un livre de développement personnel", description: "Lire au moins 20 pages avec prise de notes.", xp: 250 },
    { title: "Apprendre 20 nouveaux mots", description: "Élargir son vocabulaire dans une langue ciblée.", xp: 160 },
    { title: "Suivre un cours en ligne", description: "Terminer un module complet.", xp: 240 },
    { title: "Regarder une conférence éducative", description: "Prendre des notes exploitables.", xp: 180 },
    { title: "Faire une fiche de synthèse", description: "Résumer un chapitre ou un concept complexe.", xp: 190 },
    { title: "Résoudre 10 exercices", description: "Pratique active sur un sujet d'étude.", xp: 210 },
    { title: "Réviser 45 minutes", description: "Session de révision concentrée sans distractions.", xp: 200 },
    { title: "Lire un article scientifique", description: "Identifier thèse, méthode et conclusion.", xp: 230 },
    { title: "Apprendre un nouveau concept technique", description: "Comprendre et expliquer un concept inédit.", xp: 260 },
    { title: "Écrire un résumé de 300 mots", description: "Produire une synthèse claire et structurée.", xp: 170 },
    { title: "Faire une session de flashcards", description: "Réactiver la mémoire active.", xp: 150 },
    { title: "Visionner un tutoriel avancé", description: "Appliquer ce qui a été appris dans un mini exercice.", xp: 220 },
    { title: "Créer une carte mentale", description: "Structurer un sujet autour de ses idées clés.", xp: 180 },
    { title: "Réviser un ancien cours", description: "Consolider les bases oubliées.", xp: 160 },
    { title: "Mémoriser une définition clé", description: "Retenir et reformuler une notion importante.", xp: 120 },
    { title: "Résoudre un problème logique", description: "Appliquer une méthode de raisonnement.", xp: 210 },
    { title: "Lire 30 minutes en anglais", description: "Lecture active avec vocabulaire inconnu.", xp: 200 },
    { title: "Prendre des notes Cornell", description: "Structurer la prise de notes pour révision rapide.", xp: 170 },
    { title: "Faire une auto-évaluation", description: "Tester ses connaissances sur un thème précis.", xp: 190 },
    { title: "Terminer un mini-projet d'apprentissage", description: "Transformer une notion théorique en réalisation concrète.", xp: 340 }
  ],
  social: [
    { title: "Organiser un événement social", description: "Planifier et coordonner une activité collective.", xp: 400 },
    { title: "Prendre des nouvelles d'un proche", description: "Envoyer un message ou appeler avec attention.", xp: 130 },
    { title: "Aider un ami sur un objectif", description: "Apporter un soutien concret et utile.", xp: 180 },
    { title: "Participer à une activité de groupe", description: "S'impliquer activement dans un moment collectif.", xp: 200 },
    { title: "Rencontrer une nouvelle personne", description: "Créer un échange authentique et respectueux.", xp: 170 },
    { title: "Faire un compliment sincère", description: "Valoriser quelqu'un de manière précise et honnête.", xp: 110 },
    { title: "Résoudre un malentendu calmement", description: "Privilégier l'écoute et la communication claire.", xp: 260 },
    { title: "Partager une ressource utile", description: "Transmettre un contenu pertinent à quelqu'un.", xp: 120 },
    { title: "Déjeuner avec un collègue", description: "Créer du lien hors des échanges de travail.", xp: 150 },
    { title: "Demander un feedback constructif", description: "Recueillir un retour pour progresser.", xp: 190 },
    { title: "Donner un feedback bienveillant", description: "Aider l'autre à progresser de façon actionable.", xp: 190 },
    { title: "Animer une discussion de groupe", description: "Faciliter la prise de parole de chacun.", xp: 230 },
    { title: "Remercier 3 personnes", description: "Exprimer de la gratitude de manière concrète.", xp: 140 },
    { title: "Écouter sans interrompre", description: "Pratiquer l'écoute active sur une conversation complète.", xp: 160 },
    { title: "Relancer un contact ancien", description: "Reprendre contact de façon naturelle.", xp: 170 },
    { title: "Faire une bonne action anonyme", description: "Aider sans attendre de reconnaissance.", xp: 210 },
    { title: "Participer à une communauté", description: "Contribuer utilement dans un groupe ou forum.", xp: 220 },
    { title: "Demander de l'aide clairement", description: "Formuler un besoin précis et respectueux.", xp: 150 },
    { title: "Pratiquer l'empathie active", description: "Reformuler et valider les émotions de l'autre.", xp: 200 },
    { title: "Construire une collaboration efficace", description: "Mener une action à deux avec objectif atteint.", xp: 320 }
  ],
  defi: [
    { title: "Relever un défi en dehors de sa zone de confort", description: "Faire une action qui génère une légère peur constructive.", xp: 600 },
    { title: "Parler en public 5 minutes", description: "Prendre la parole devant un petit groupe.", xp: 320 },
    { title: "Se lancer dans une nouvelle activité", description: "Tester une discipline jamais pratiquée.", xp: 260 },
    { title: "Passer une journée sans sucre", description: "Tenir une contrainte alimentaire volontaire.", xp: 180 },
    { title: "Prendre une douche froide", description: "Sortir de sa zone de confort physique.", xp: 170 },
    { title: "Faire 24h sans réseaux sociaux", description: "Couper les plateformes sociales pendant une journée.", xp: 240 },
    { title: "Réussir un challenge créatif", description: "Produire quelque chose en un temps limité.", xp: 250 },
    { title: "Dire non à une distraction majeure", description: "Protéger son temps sur une décision difficile.", xp: 210 },
    { title: "Terminer une tâche repoussée depuis 1 mois", description: "Clore un dossier en attente longue.", xp: 340 },
    { title: "Faire 12 heures sans plainte", description: "Maintenir une posture mentale constructive.", xp: 190 },
    { title: "Prendre une décision difficile", description: "Trancher avec clarté malgré l'incertitude.", xp: 280 },
    { title: "Demander un retour honnête", description: "S'exposer à une critique utile.", xp: 220 },
    { title: "Commencer un projet ambitieux", description: "Poser la première brique d'un objectif important.", xp: 300 },
    { title: "Publier une création personnelle", description: "Partager publiquement un travail personnel.", xp: 270 },
    { title: "Tenir un engagement difficile", description: "Respecter une promesse malgré la difficulté.", xp: 260 },
    { title: "Tester une routine inconfortable", description: "Adopter un nouveau cadre pendant 3 jours.", xp: 230 },
    { title: "Apprendre de l'échec d'hier", description: "Transformer une erreur en action concrète.", xp: 200 },
    { title: "Faire une action courageuse", description: "Agir malgré la peur sur un sujet important.", xp: 290 },
    { title: "Rompre avec une mauvaise habitude", description: "Interrompre un schéma limitant toute la journée.", xp: 250 },
    { title: "Réussir un défi personnel de 7 jours", description: "Tenir un challenge complet sur une semaine.", xp: 420 }
  ]
}

quest_catalog.each do |category_key, items|
  items.each do |item|
    Quest.find_or_create_by!(title: item[:title]) do |quest|
      quest.description = item[:description]
      quest.xp = item[:xp]
      quest.category = categories[category_key]
      quest.valid_until = 1.week.from_now
    end
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
