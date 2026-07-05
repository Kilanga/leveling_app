# Catalogue officiel des quêtes du Système (V2, ton Solo Leveling).
# Source de vérité unique : utilisé par db/seeds.rb et par la migration de
# données qui réécrit le catalogue en production (mapping via legacy_title).
#
# XP rééquilibré : chaque difficulté (alignée sur les rangs E→S) a un XP fixe.
class QuestCatalog
  XP_BY_DIFFICULTY = {
    "E" => 100,
    "D" => 150,
    "C" => 220,
    "B" => 300,
    "A" => 420,
    "S" => 600
  }.freeze

  ENTRIES = {
    "Discipline" => [
      { legacy_title: "Compléter un exercice de concentration", title: "Œil du chasseur : 10 minutes de focus absolu", description: "Reste sur une seule tâche pendant 10 minutes, sans la moindre distraction.", difficulty: "D" },
      { legacy_title: "Planifier la journée en 5 priorités", title: "Ordre de mission : 5 priorités pour la journée", description: "Établis un plan clair et réaliste avant de te lancer dans la journée.", difficulty: "E" },
      { legacy_title: "Se lever sans snooze", title: "Réveil du chasseur : debout à la première alarme", description: "Sors du lit dès la première sonnerie. Le Système n'accorde pas de report.", difficulty: "D" },
      { legacy_title: "Tenir un journal d'habitudes", title: "Rapport quotidien : journal d'habitudes à jour", description: "Consigne tes habitudes du jour comme un rapport remis au Système.", difficulty: "D" },
      { legacy_title: "Bloquer 1h de travail profond", title: "Donjon de focus : 1 heure de travail profond", description: "Travaille 1 heure sans notification ni interruption. Personne n'entre dans le donjon.", difficulty: "C" },
      { legacy_title: "Ranger son espace de travail", title: "Préparation du camp : espace de travail net", description: "Débarrasse ton bureau pour créer un terrain propice à la chasse.", difficulty: "E" },
      { legacy_title: "Respecter sa routine matinale", title: "Rituel d'aube : routine matinale sans faille", description: "Exécute chaque étape de ta routine, sans en sauter une seule.", difficulty: "C" },
      { legacy_title: "Éteindre les écrans avant minuit", title: "Couvre-feu : écrans éteints 30 minutes avant le coucher", description: "Coupe tous les écrans pour préparer la régénération nocturne.", difficulty: "D" },
      { legacy_title: "Préparer ses tâches du lendemain", title: "Plan de raid : le lendemain déjà tracé", description: "Liste les missions prioritaires de demain avant de clore la journée.", difficulty: "E" },
      { legacy_title: "Terminer une tâche commencée", title: "Contrat rempli : aucune tâche abandonnée", description: "Finalise une tâche en cours au lieu de la repousser.", difficulty: "C" },
      { legacy_title: "Faire une pause consciente", title: "Trêve du chasseur : 10 minutes sans téléphone", description: "Prends une vraie pause de 10 minutes, téléphone hors de portée.", difficulty: "E" },
      { legacy_title: "Réviser ses objectifs hebdomadaires", title: "Conseil de guerre : objectifs de la semaine révisés", description: "Mets à jour et clarifie tes objectifs hebdomadaires.", difficulty: "D" },
      { legacy_title: "Supprimer 20 distractions numériques", title: "Purge de l'inventaire : 20 distractions supprimées", description: "Nettoie onglets, notifications et applications inutiles.", difficulty: "C" },
      { legacy_title: "Travailler en mode Pomodoro x4", title: "Assaut en 4 vagues : Pomodoro x4", description: "Enchaîne 4 cycles complets de focus et de pause.", difficulty: "B" },
      { legacy_title: "Finir une tâche difficile en premier", title: "Le boss d'abord : la tâche la plus dure en premier", description: "Attaque la mission la plus difficile avant tout le reste.", difficulty: "B" },
      { legacy_title: "Respecter une heure de coucher fixe", title: "Régénération programmée : coucher à heure fixe", description: "Couche-toi dans ton créneau cible, sans négociation.", difficulty: "C" },
      { legacy_title: "Faire un bilan de fin de journée", title: "Débriefing du Système : bilan de fin de journée", description: "Analyse ce qui a été accompli et ce qui bloque encore.", difficulty: "D" },
      { legacy_title: "Ne pas procrastiner sur une tâche clé", title: "Frappe immédiate : zéro procrastination sur la priorité n°1", description: "Passe à l'action immédiatement sur ta tâche la plus importante.", difficulty: "B" },
      { legacy_title: "Limiter les réseaux à 20 minutes", title: "Sceau de restriction : réseaux limités à 20 minutes", description: "Tiens une limite stricte d'usage des réseaux sur toute la journée.", difficulty: "A" },
      { legacy_title: "Maintenir 3 jours de routine", title: "Épreuve de rang : 3 jours de routine sans rupture", description: "Tiens ta discipline complète pendant 3 jours consécutifs.", difficulty: "S" }
    ],
    "Physique" => [
      { legacy_title: "Faire une séance de sport intense", title: "Raid complet : séance de sport intense", description: "Séance complète avec échauffement et retour au calme.", difficulty: "B" },
      { legacy_title: "Faire 30 minutes de cardio", title: "Traque matinale : 30 minutes de cardio", description: "Course, vélo ou corde à sauter, sans interruption.", difficulty: "C" },
      { legacy_title: "Atteindre 10 000 pas", title: "Patrouille longue : 10 000 pas", description: "Bouge activement tout au long de la journée.", difficulty: "C" },
      { legacy_title: "Réaliser une séance de mobilité", title: "Entretien de l'arme : séance de mobilité", description: "Travaille tes articulations et ton amplitude de mouvement.", difficulty: "D" },
      { legacy_title: "Faire 50 pompes cumulées", title: "Tribut de force : 50 pompes cumulées", description: "Répartis les séries sur la journée si nécessaire.", difficulty: "C" },
      { legacy_title: "Tenir 5 minutes de gainage", title: "Posture du gardien : 5 minutes de gainage", description: "Cumule des planches de qualité.", difficulty: "D" },
      { legacy_title: "Faire une sortie à vélo", title: "Chevauchée : 45 minutes de vélo", description: "Sortie d'au moins 45 minutes.", difficulty: "C" },
      { legacy_title: "S'hydrater correctement", title: "Potion de régénération : hydratation complète", description: "Atteins ton objectif d'hydratation du jour.", difficulty: "E" },
      { legacy_title: "S'étirer 15 minutes", title: "Déverrouillage du corps : 15 minutes d'étirements", description: "Routine complète haut et bas du corps.", difficulty: "E" },
      { legacy_title: "Monter les escaliers 20 fois", title: "Ascension de la tour : 20 montées d'escaliers", description: "Remplace l'ascenseur par les escaliers.", difficulty: "D" },
      { legacy_title: "Faire un entraînement HIIT", title: "Combat en zone rouge : séance HIIT", description: "Fractionné de 20 minutes minimum, intensité maximale.", difficulty: "A" },
      { legacy_title: "Courir 5 km", title: "Poursuite : 5 km de course", description: "Gère ton allure et ta respiration sur toute la distance.", difficulty: "B" },
      { legacy_title: "Faire une séance jambes", title: "Fondations du chasseur : séance jambes", description: "Squats, fentes et renforcement ciblé.", difficulty: "B" },
      { legacy_title: "Faire une séance haut du corps", title: "Armure du haut du corps : dos, épaules, bras", description: "Dos, épaules, pectoraux et bras.", difficulty: "B" },
      { legacy_title: "Récupération active", title: "Repos du chasseur : récupération active", description: "Marche et mobilité légère pour relancer la circulation.", difficulty: "E" },
      { legacy_title: "Tenir une posture correcte toute la journée", title: "Stature de rang A : posture tenue toute la journée", description: "Vigilance continue sur ton alignement corporel.", difficulty: "D" },
      { legacy_title: "Faire 100 squats cumulés", title: "Épreuve des jambes : 100 squats cumulés", description: "Objectif volume sur la journée.", difficulty: "C" },
      { legacy_title: "Faire 60 minutes de marche rapide", title: "Marche forcée : 60 minutes à allure soutenue", description: "Rythme rapide et régulier, sans pause.", difficulty: "C" },
      { legacy_title: "Dormir au moins 8 heures", title: "Sommeil de régénération : 8 heures minimum", description: "Optimise ta récupération physique.", difficulty: "D" },
      { legacy_title: "Enchaîner 4 entraînements dans la semaine", title: "Semaine de siège : 4 entraînements enchaînés", description: "Tiens ta régularité sportive sur plusieurs jours.", difficulty: "S" }
    ],
    "Savoir" => [
      { legacy_title: "Lire un livre de développement personnel", title: "Grimoire de croissance : 20 pages annotées", description: "Lis au moins 20 pages avec prise de notes.", difficulty: "C" },
      { legacy_title: "Apprendre 20 nouveaux mots", title: "Fragments de langue : 20 mots nouveaux", description: "Élargis ton vocabulaire dans une langue ciblée.", difficulty: "D" },
      { legacy_title: "Suivre un cours en ligne", title: "Salle d'entraînement : un module de cours terminé", description: "Termine un module complet.", difficulty: "C" },
      { legacy_title: "Regarder une conférence éducative", title: "Audience avec un maître : une conférence, des notes", description: "Prends des notes exploitables.", difficulty: "D" },
      { legacy_title: "Faire une fiche de synthèse", title: "Cristallisation du savoir : une fiche de synthèse", description: "Résume un chapitre ou un concept complexe.", difficulty: "C" },
      { legacy_title: "Résoudre 10 exercices", title: "Série de combats : 10 exercices résolus", description: "Pratique active sur un sujet d'étude.", difficulty: "C" },
      { legacy_title: "Réviser 45 minutes", title: "Méditation studieuse : 45 minutes de révision", description: "Session concentrée, sans distraction.", difficulty: "C" },
      { legacy_title: "Lire un article scientifique", title: "Décryptage d'archive : un article scientifique", description: "Identifie thèse, méthode et conclusion.", difficulty: "B" },
      { legacy_title: "Apprendre un nouveau concept technique", title: "Éveil de compétence : un concept technique maîtrisé", description: "Comprends puis explique un concept inédit.", difficulty: "A" },
      { legacy_title: "Écrire un résumé de 300 mots", title: "Rapport de mission : résumé en 300 mots", description: "Produis une synthèse claire et structurée.", difficulty: "D" },
      { legacy_title: "Faire une session de flashcards", title: "Entraînement mémoire : session de flashcards", description: "Réactive ta mémoire active.", difficulty: "E" },
      { legacy_title: "Visionner un tutoriel avancé", title: "Technique secrète : tutoriel avancé appliqué", description: "Applique ce que tu viens d'apprendre dans un mini exercice.", difficulty: "B" },
      { legacy_title: "Créer une carte mentale", title: "Cartographie du donjon : une carte mentale", description: "Structure un sujet autour de ses idées clés.", difficulty: "D" },
      { legacy_title: "Réviser un ancien cours", title: "Retour aux fondamentaux : un ancien cours révisé", description: "Consolide les bases oubliées.", difficulty: "D" },
      { legacy_title: "Mémoriser une définition clé", title: "Gravure mentale : une définition clé retenue", description: "Retiens et reformule une notion importante.", difficulty: "E" },
      { legacy_title: "Résoudre un problème logique", title: "Énigme du Système : un problème logique résolu", description: "Applique une méthode de raisonnement.", difficulty: "D" },
      { legacy_title: "Lire 30 minutes en anglais", title: "Langue des autres guildes : 30 minutes de lecture en anglais", description: "Lecture active avec relevé du vocabulaire inconnu.", difficulty: "C" },
      { legacy_title: "Prendre des notes Cornell", title: "Codex du chasseur : prise de notes Cornell", description: "Structure tes notes pour une révision rapide.", difficulty: "D" },
      { legacy_title: "Faire une auto-évaluation", title: "Jauge de niveau : auto-évaluation complète", description: "Teste tes connaissances sur un thème précis.", difficulty: "D" },
      { legacy_title: "Terminer un mini-projet d'apprentissage", title: "Artefact forgé : mini-projet d'apprentissage terminé", description: "Transforme la théorie en réalisation concrète.", difficulty: "S" }
    ],
    "Social" => [
      { legacy_title: "Organiser un événement social", title: "Rassemblement de guilde : un événement organisé", description: "Planifie et coordonne une activité collective.", difficulty: "S" },
      { legacy_title: "Prendre des nouvelles d'un proche", title: "Lien d'allié : des nouvelles d'un proche", description: "Envoie un message ou appelle avec une vraie attention.", difficulty: "E" },
      { legacy_title: "Aider un ami sur un objectif", title: "Quête d'escorte : un ami aidé sur son objectif", description: "Apporte un soutien concret et utile.", difficulty: "C" },
      { legacy_title: "Participer à une activité de groupe", title: "Chasse en équipe : une activité de groupe", description: "Implique-toi activement dans un moment collectif.", difficulty: "C" },
      { legacy_title: "Rencontrer une nouvelle personne", title: "Nouvelle alliance : une personne rencontrée", description: "Crée un échange authentique et respectueux.", difficulty: "B" },
      { legacy_title: "Faire un compliment sincère", title: "Mot de pouvoir : un compliment sincère", description: "Valorise quelqu'un de manière précise et honnête.", difficulty: "E" },
      { legacy_title: "Résoudre un malentendu calmement", title: "Désamorçage : un malentendu résolu dans le calme", description: "Privilégie l'écoute et la communication claire.", difficulty: "A" },
      { legacy_title: "Partager une ressource utile", title: "Butin partagé : une ressource utile transmise", description: "Transmets un contenu pertinent à quelqu'un.", difficulty: "E" },
      { legacy_title: "Déjeuner avec un collègue", title: "Table commune : un déjeuner avec un collègue", description: "Crée du lien hors des échanges de travail.", difficulty: "D" },
      { legacy_title: "Demander un feedback constructif", title: "Évaluation extérieure : un feedback demandé", description: "Recueille un retour pour progresser.", difficulty: "C" },
      { legacy_title: "Donner un feedback bienveillant", title: "Transmission : un feedback bienveillant donné", description: "Aide l'autre à progresser de façon actionnable.", difficulty: "C" },
      { legacy_title: "Animer une discussion de groupe", title: "Voix du meneur : une discussion animée", description: "Facilite la prise de parole de chacun.", difficulty: "B" },
      { legacy_title: "Remercier 3 personnes", title: "Tribut de gratitude : 3 personnes remerciées", description: "Exprime ta gratitude de manière concrète.", difficulty: "D" },
      { legacy_title: "Écouter sans interrompre", title: "Silence du traqueur : écoute sans interruption", description: "Écoute active sur une conversation complète.", difficulty: "D" },
      { legacy_title: "Relancer un contact ancien", title: "Portail rouvert : un ancien contact relancé", description: "Reprends contact de façon naturelle.", difficulty: "D" },
      { legacy_title: "Faire une bonne action anonyme", title: "Ombre bienfaitrice : une bonne action anonyme", description: "Aide sans attendre de reconnaissance.", difficulty: "C" },
      { legacy_title: "Participer à une communauté", title: "Guilde active : une contribution à ta communauté", description: "Contribue utilement dans un groupe ou un forum.", difficulty: "C" },
      { legacy_title: "Demander de l'aide clairement", title: "Appel au renfort : une demande d'aide claire", description: "Formule un besoin précis et respectueux.", difficulty: "D" },
      { legacy_title: "Pratiquer l'empathie active", title: "Lecture d'âme : empathie active pratiquée", description: "Reformule et valide les émotions de l'autre.", difficulty: "C" },
      { legacy_title: "Construire une collaboration efficace", title: "Pacte de chasse : une collaboration menée à bien", description: "Mène une action à deux jusqu'à l'objectif.", difficulty: "B" }
    ],
    "Défi" => [
      { legacy_title: "Relever un défi en dehors de sa zone de confort", title: "Sortie de la zone sûre : un défi hors de ta zone de confort", description: "Fais une action qui génère une peur constructive.", difficulty: "S" },
      { legacy_title: "Parler en public 5 minutes", title: "Face à la foule : 5 minutes de prise de parole", description: "Prends la parole devant un groupe.", difficulty: "A" },
      { legacy_title: "Se lancer dans une nouvelle activité", title: "Terre inconnue : une activité jamais pratiquée", description: "Teste une discipline totalement nouvelle.", difficulty: "B" },
      { legacy_title: "Passer une journée sans sucre", title: "Jeûne du chasseur : une journée sans sucre", description: "Tiens une contrainte alimentaire volontaire.", difficulty: "C" },
      { legacy_title: "Prendre une douche froide", title: "Baptême de glace : une douche froide", description: "Sors de ta zone de confort physique.", difficulty: "D" },
      { legacy_title: "Faire 24h sans réseaux sociaux", title: "Blackout : 24 heures sans réseaux sociaux", description: "Coupe les plateformes sociales pendant une journée entière.", difficulty: "B" },
      { legacy_title: "Réussir un challenge créatif", title: "Forge express : un challenge créatif réussi", description: "Produis quelque chose en temps limité.", difficulty: "C" },
      { legacy_title: "Dire non à une distraction majeure", title: "Volonté de fer : non à une distraction majeure", description: "Protège ton temps sur une décision difficile.", difficulty: "D" },
      { legacy_title: "Terminer une tâche repoussée depuis 1 mois", title: "Dette réglée : la tâche repoussée depuis un mois", description: "Clos enfin ce dossier en attente.", difficulty: "A" },
      { legacy_title: "Faire 12 heures sans plainte", title: "Mental d'acier : 12 heures sans une plainte", description: "Garde une posture mentale constructive.", difficulty: "C" },
      { legacy_title: "Prendre une décision difficile", title: "Jugement : une décision difficile tranchée", description: "Tranche avec clarté malgré l'incertitude.", difficulty: "C" },
      { legacy_title: "Demander un retour honnête", title: "Miroir sans filtre : un retour honnête demandé", description: "Expose-toi à une critique utile.", difficulty: "C" },
      { legacy_title: "Commencer un projet ambitieux", title: "Première pierre : un projet ambitieux lancé", description: "Pose la première brique d'un objectif important.", difficulty: "B" },
      { legacy_title: "Publier une création personnelle", title: "Révélation : une création personnelle publiée", description: "Partage publiquement un travail personnel.", difficulty: "B" },
      { legacy_title: "Tenir un engagement difficile", title: "Parole de chasseur : un engagement difficile tenu", description: "Respecte ta promesse malgré la difficulté.", difficulty: "C" },
      { legacy_title: "Tester une routine inconfortable", title: "Camp d'entraînement : 3 jours de routine inconfortable", description: "Adopte un nouveau cadre exigeant pendant 3 jours.", difficulty: "A" },
      { legacy_title: "Apprendre de l'échec d'hier", title: "Autopsie du combat : une leçon tirée de l'échec", description: "Transforme une erreur en action concrète.", difficulty: "D" },
      { legacy_title: "Faire une action courageuse", title: "Cœur de rang S : une action courageuse", description: "Agis malgré la peur sur un sujet important.", difficulty: "B" },
      { legacy_title: "Rompre avec une mauvaise habitude", title: "Chaîne brisée : une journée sans ta mauvaise habitude", description: "Interromps un schéma limitant toute la journée.", difficulty: "C" },
      { legacy_title: "Réussir un défi personnel de 7 jours", title: "Épreuve des 7 jours : un défi personnel accompli", description: "Tiens un challenge complet sur une semaine.", difficulty: "S" }
    ]
  }.freeze

  class << self
    # Crée ou met à jour chaque quête du catalogue.
    # Les quêtes existantes sont retrouvées par leur nouveau titre, ou par
    # leur ancien titre (legacy_title) pour la migration en production —
    # ce qui préserve les user_quests et l'historique des joueurs.
    def sync!
      ENTRIES.each do |category_name, entries|
        category = Category.find_or_create_by!(name: category_name)

        entries.each do |entry|
          quest = Quest.find_by(title: entry[:title]) || Quest.find_by(title: entry[:legacy_title])
          quest ||= Quest.new

          quest.assign_attributes(
            title: entry[:title],
            description: entry[:description],
            difficulty: entry[:difficulty],
            xp: XP_BY_DIFFICULTY.fetch(entry[:difficulty]),
            category: category
          )
          quest.valid_until ||= 10.years.from_now
          quest.save!
        end
      end

      true
    end
  end
end
