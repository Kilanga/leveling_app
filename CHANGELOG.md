# Journal des modifications

Toutes les modifications notables de ce projet sont documentées dans ce fichier.

Le format suit [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) (version du format, pas version de l'app),
et ce projet respecte [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Regle simple de versioning:
- PATCH (x.y.Z): correctifs et petits ajustements sans impact structurel
- MINOR (x.Y.0): nouvelles fonctionnalites ou changements structurants compatibles
- MAJOR (X.0.0): rupture de compatibilite

Regle de normalisation Keep a Changelog:
- Sous-sections autorisees: `Ajouté`, `Modifié`, `Corrigé`, `Supprimé`, `Déprécié`, `Sécurité`
- Les anciens intitulés non standards (ex: `Tests`, `Améliorations UI`) sont ramenés a `Modifié`
- Toute nouvelle ligne ajoutee au changelog est publiee immediatement dans une version datee (pas d'entree conservee en attente dans `Non publié`).

## [Non publié]

## [1.15.4] - 2026-03-27

### Modifié
- Accueil joueur public: ajout du bloc "Quetes en cours" sous "Quetes hebdomadaires".
- Affichage compact limite aux 2 premieres quetes en cours, avec indicateur `+X` quand d'autres quetes actives existent.

## [1.15.3] - 2026-03-27

### Modifié
- Vue joueur depuis le classement: remplacement du profil public par l'Accueil joueur en lecture seule (dashboard de progression, quetes hebdo, activite recente, stats), sans actions de modification.
- Positionnement UX clarifie: le profil personnel reste l'espace de personnalisation, la vue publique sert de vitrine de progression.
- Bloc d'apercu profil boutique enrichi pour visualiser concretement l'impact des cosmetiques (cadre, barre XP thematisee, carte de visite).

### Corrigé
- Amelioration visuelle des apercus cosmetiques: barres XP et cartes de visite retravaillees pour un rendu plus lisible et plus premium.

## [1.15.2] - 2026-03-27

### Corrigé
- Boutique cosmétiques: correction d'une erreur 500 sur `/purchases/new?tab=cosmetics` quand l'environnement n'a pas encore les colonnes `active_profile_frame_id`, `active_xp_theme_id` et `active_profile_card_id`.
- Ajout d'un mode de compatibilité temporaire: les apercus et achats restent visibles, et l'activation est masquée avec un message explicite tant que la migration DB n'est pas appliquée.
- Mapping des classes CSS cosmétiques rendu robuste aux noms complets des items (ex: `Cadre Standard`, `Theme XP Neon`, `Carte de Visite Royale`).

## [1.15.1] - 2026-03-27

### Modifié
- Affichage des cadres de profil autour du pseudo au classement avec 3 styles visuels (Standard bleu, Électrique violet luminescent, Légendaire or étincelant).
- Application des thèmes de barre XP au dashboard: couleurs dynamiques selon le thème actif (Standard bleu, Samouraï rouge, Neon vert, Légendaire or).
- Affichage des cartes de visite personnalisées au profil public des joueurs (texte custom + style visuel thématisé).
- Helpers cosmétiques créés pour générer classes CSS optimisées.

## [1.15.0] - 2026-03-27

### Ajouté
- Cadres de profil: cosmétiques pour encadrer le pseudo au classement avec 3 styles (Standard bleu, Électrique violet, Légendaire or).
- Thèmes de barre XP: personnalisation de l'apparence des barres de progression avec 4 thèmes (Standard, Samouraï rouge, Neon vert, Légendaire or-violet).
- Cartes de visite: cosmétiques personnalisables affichées au profil joueur visible par les autres (texte custom + thème) avec 4 styles de cartes.
- Onglet "Titres" séparé en boutique pour meilleure visualisation.
- Gestion des cosmétiques au profil personnel: activation/désactivation des cadres, thèmes et cartes de visite.

### Modifié
- Boutique: réorganisation avec 4 onglets (Packs, Boosts, Titres, Cosmétiques).
- Profil personnel: ajout d'une section "Cosmétiques" pour piloter les préférences visuelles.
- Panier cosmétiques: intégration avec le système d'achat existant (coins et EUR).

## [1.14.1] - 2026-03-27

### Modifié
- Recommandations de quetes personnalisees: ciblage selon categories prioritaires d'onboarding, historique recent, categories fortes/faibles et niveau de difficulte adapte au rythme XP joueur.
- Onglet Quetes: affichage d'un motif de recommandation pour chaque mission proposee dans le bloc "Recommandees pour toi".

## [1.14.0] - 2026-03-27

### Ajouté
- Parrainage: systeme de recompense double actif apres la premiere quete validee du filleul (+50 coins filleul, +100 coins parrain), avec attribution unique et anti auto-parrainage.
- Inscription: champ de code parrainage (`referral_code_input`) pour rattacher un nouvel utilisateur a un parrain des la creation du compte.

### Modifié
- Onglet Amis: texte de parrainage enrichi pour afficher clairement les gains de chaque role.
- Completion de quete: message de succes enrichi quand une recompense parrainage est debloquee.

## [1.13.1] - 2026-03-27

### Modifié
- Parrainage: deplacement du module de partage depuis le dashboard vers l'onglet Amis pour centraliser les actions sociales.
- Dashboard: retrait du bloc de parrainage pour garder une page centree progression.

## [1.13.0] - 2026-03-27

### Ajouté
- Landing page publique orientee desirabilite (`/welcome`) avec proposition de valeur claire, CTA inscription/connexion et preuve sociale de base.
- Dashboard: bloc de partage avec lien d'invitation pre-rempli pour faciliter la promotion organique entre joueurs.
- Modele utilisateur: generation d'un code d'invitation stable (`referral_code`) utilise dans les liens de partage.

### Modifié
- Navigation racine: `root` pointe vers la landing publique, avec redirection automatique vers le dashboard pour les utilisateurs connectes.
- Meta SEO: titre et description dedies a la landing pour mieux soutenir l'acquisition.

## [1.12.4] - 2026-03-27

### Modifié
- Ligues: ajout de tests de non-regression sur les bornes de mouvement (pas de promotion au-dessus de Diamond, pas de relegation sous Bronze) pour securiser les semaines suivantes.

## [1.12.3] - 2026-03-27

### Modifié
- Classement ligue: remplacement des libelles UP/DOWN/HOLD par des fleches colorees (▲/▼/•) pour une lecture plus immediate.

### Corrigé
- Projection de mouvement: application des zones de promotion/relegation des 3 joueurs de cohorte (minimum), avec conservation du taux a 20%.

## [1.12.2] - 2026-03-27

### Corrigé
- Classement ligue: correction de la mise en avant de la ligne du joueur courant pour conserver un contraste lisible sur le theme sombre.
- Classement ligue: correction de la projection de mouvement sur petites cohortes (ex: 4 joueurs) pour eviter un affichage integralement en HOLD.

## [1.12.1] - 2026-03-27

### Modifié
- Classement ligue: suppression du filtre categorie pour simplifier la lecture et se concentrer sur la cohorte de ligue du joueur.
- Classement ligue: ajout d'un indicateur de tendance par rang (UP/DOWN/HOLD) avec codes visuels vert/rouge/neutre pour mieux voir la projection de mouvement.

## [1.12.0] - 2026-03-27

### Ajouté
- Systeme de ligues etendu a 5 tiers: Bronze, Silver, Gold, Platinum et Diamond.
- Mecanique hebdomadaire de promotion/relegation entre ligues selon la performance relative dans chaque tier.
- Distribution automatique des joueurs en cohortes techniques de 50 par ligue (rooms backend invisibles pour le joueur).

### Modifié
- Classement ligue: affichage du classement complet de la cohorte de ligue du joueur, avec zone scrollable (environ 20 lignes visibles).
- UX ligue: le concept de room reste strictement interne et n'apparait pas dans l'interface.

## [1.11.8] - 2026-03-27

### Modifié
- Onglet Classement: suppression du tableau de ranking XP global pour passer sur une lecture ligue-first.
- Onglet Classement: conservation du Top 10 avec affichage centre sur la ligue hebdomadaire (rang, joueur, XP semaine, tier).

## [1.11.7] - 2026-03-27

### Corrigé
- Production: suppression du 500 sur le dashboard quand les colonnes de bonus de connexion quotidienne ne sont pas encore migrees en base.

### Modifié
- Onglet Classement: ajout d'un bloc dedie "Top ligue hebdomadaire" pour afficher clairement le classement de ligue.

## [1.11.6] - 2026-03-27

### Modifié
- Onglet Amis: ajout des sections "Quetes les plus realisees par mes amis" et "Dernieres quetes realisees par mes amis".
- Onglet Classement: retrait de ces deux sections pour recentrer la page sur le ranking et la ligue.

## [1.11.5] - 2026-03-27

### Modifié
- Ligue: retrait de l'affichage ligue du dashboard pour centraliser la fonctionnalite dans l'onglet Classement.
- Classement: limite stricte a 10 joueurs affiches, y compris en mode global et avec filtre categorie.
- Classement: ajout d'une indication explicite en interface sur la limite Top 10 pour le filtre actif.

## [1.11.4] - 2026-03-27

### Ajouté
- Dashboard: bonus de connexion quotidienne avec progression de serie (streak) et recompense en coins.
- Dashboard: coffre quotidien reclamable apres l'objectif journalier de quetes, avec protection anti double-claim.
- Dashboard: feed d'activite recente des amis (quetes completees, quete hebdo, coffre quotidien, amitie acceptee).

### Modifié
- Engagement loop: objectif quotidien relie a une recompense tangible (coffre) pour renforcer la retention sans dupliquer les mecaniques de ligue/leaderboard.

## [1.11.3] - 2026-03-27

### Modifié
- Dashboard: suppression du bloc d'appel a l'action Tutoriel.
- Navigation: suppression de l'onglet Tutoriel.

### Supprimé
- Tutoriel complet retire de l'application (routes, controller, vue et JavaScript associe).
- Endpoint de recommandations Tutoriel et logique de completion/skip associee.

## [1.11.2] - 2026-03-27

### Corrigé
- Route onboarding: liaison explicite vers `OnboardingController` pour eviter l'erreur 500 `uninitialized constant OnboardingsController`.
- Tutoriel: les missions recommandees sont maintenant chargees via endpoint backend au changement de categories, avec affichage fiable sans rechargement.
- Chargement JS tutoriel: pin importmap ajoute pour garantir l'activation du comportement dynamique en production.

### Modifié
- Boutique packs: clarification visuelle de l'offre de bienvenue avec total de coins recu mis en avant et detail base + bonus sur chaque pack.
- Terminologie UX: l'onboarding est renomme en "Tutoriel" dans la navigation et le dashboard pour clarifier son role.
- Tutoriel: possibilite de selectionner directement les missions a suivre avant validation finale.
- Tutoriel: validation finale exige au moins une mission selectionnee, avec bouton "Passer" pour ignorer le setup mission.
- Navigation: onglet Tutoriel masque apres completion et route rendue inaccessible une fois le tutoriel termine.

## [1.11.1] - 2026-03-27


### Modifié
- Boutique: l'offre de bienvenue est maintenant integree dans le calcul des packs coins (bonus applique selon variante) et visible directement dans l'affichage des prix/valeur.
- Ecran Amis: refonte visuelle des sections et des listes de demandes pour harmoniser avec le style HUD de l'application.

### Corrigé
- Onboarding: prevention des erreurs 500 dans les cas de donnees manquantes ou de contexte partiellement indisponible, avec fallback propre et messages utilisateur.
- Onboarding: affichage des quetes recommandees rendu tolerant si une categorie est indisponible.

## [1.11.0] - 2026-03-27

### Ajouté
- Onboarding complet en 2 etapes: choix de categories prioritaires + recommandations de quetes personnalisees
- Notifications in-app avec statut lu/non lu et action de consultation rapide
- Defis entre amis (duel 48h) avec resolution automatique, gagnant et recompense en coins
- Ligues hebdomadaires (Bronze/Silver/Gold) affichees sur dashboard et leaderboard
- Analytics produit admin (activation, volume d'evenements, quetes completees, defis, claims boutique)
- Tracking produit structure (`ProductEvent`) pour suivre activation, progression, social et monetisation
- Infrastructure d'A/B test (`ExperimentAssignment` + `Experimentation`) avec premiere experience sur l'offre d'entree boutique

### Modifié
- Dashboard enrichi: CTA onboarding, synthese streak hebdo, classement ligue hebdomadaire
- Profil enrichi en vitrine joueur: KPI progression et historique de defis termines
- Ecran Amis enrichi: lancement de defis et suivi des defis actifs
- Navbar enrichie: acces onboarding, notifications et analytics admin

### Corrigé
- Stabilisation environnement dev/test: Dev Container outille (Ruby 3.2.10 + dependances natives), PostgreSQL local et fiabilisation de la suite
- Fiabilisation tooling Ruby: Ruby LSP via Bundler
- Correction logique achat: suppression du callback de credit auto obsolete pour eviter les credits de coins indus
- Reduction du bruit d'execution (Sass deps) via option `--quiet-deps`

## [1.10.2] - 2026-03-27

### Corrigé
- Corrections des line endings (CRLF → LF) pour compatibilité Docker et tests en conteneur (`.gitattributes` global)
- Dockerfile: utilisation de `bundle exec rails` au lieu de `./bin/rails` pour éviter problèmes line endings

## [1.10.1] - 2026-03-27

### Ajouté
- Configuration Dev Container (`.devcontainer/devcontainer.json`) pour un environnement de dev standardisé avec Ruby 3.2.2
- Fichier `.ruby-version` pour gestion automatique des versions avec rbenv/asdf
- Support des tests dans Dev Container ou en local avec Ruby 3.2.x

## [1.10.0] - 2026-03-27

### Modifié
- Courbe XP de niveau remplacee par une formule monotone continue pour supprimer les chutes de difficulte entre paliers
- Harmonisation des calculs d'XP du dashboard via `XpCalculator` (suppression de la duplication de formule)
- Difficultes quetes (Easy/Medium/Hard) rendues dynamiques selon la distribution XP des quetes filtrees
- Quete hebdo globale: reduction de la repetition avec exclusion des themes recents (fenetre glissante)

### Corrigé
- Anti-spam demandes d'amis: limite a 10 demandes envoyees par joueur et par jour

## [1.9.3] - 2026-03-27

### Corrigé
- Titres communs: correction des objectifs hebdomadaires pour correspondre au design "1 quete hebdo par semaine" (passage sur un cumul total de quetes hebdo completees)

## [1.9.2] - 2026-03-27

### Modifié
- Reequilibrage des titres communs debloquables pour mieux coller au nouveau rythme de progression (objectifs plus progressifs et moins immediats)

## [1.9.1] - 2026-03-27

### Modifié
- Reequilibrage de la difficulte des titres debloquables (rare/epic/legendary) avec des objectifs plus exigeants
- Ajustement des criteres de progression utilises par `TitleUnlocker` (niveaux de categorie, XP par categorie et volume de quetes)

## [1.9.0] - 2026-03-27

### Modifié
- Refonte de l'attribution XP vers une progression parallele: bonus de streak, bonus de regularite hebdo, catch-up pour bas niveaux de categorie et bonus "Elite" sur grosses quetes
- Harmonisation du gain d'XP global utilisateur et XP de categorie pour les quetes normales et hebdomadaires
- Affichage du gain d'XP reel dans les messages de completion des quetes
- Ajout d'un marquage visuel "Elite" dans le catalogue des quetes

## [1.8.0] - 2026-03-27

### Modifié
- Boutique: affichage du nombre de coins du joueur en haut de page
- Profil joueur depuis le leaderboard: ajout du bouton "Demander en ami"

### Corrigé
- Limitation des demandes d'amis en attente a 20 par joueur cible, avec message explicite si la limite est atteinte

## [1.7.6] - 2026-03-27

### Modifié
- Ajout des meta tags `title` et `description` par page avec fallback global pour ameliorer le SEO
- Remplacement de l'intitule navigateur "Leveling App" par "Leveling"
- Ajout d'un petit logo SVG utilise comme favicon et dans la barre de navigation

## [1.7.5] - 2026-03-27

### Corrigé
- Boutique: suppression de la phrase suffixe commune ajoutee automatiquement aux descriptions, pour conserver le texte specifique de chaque titre
- Titres vendus: descriptions raccourcies en une seule phrase, differente pour chaque titre

## [1.7.4] - 2026-03-27

### Corrigé
- Seed Heroku: suppression de la dependance `faker` dans `db/seeds.rb` pour permettre `rails db:seed` en production sans gem non installee

## [1.7.3] - 2026-03-27

### Modifié
- Boutique cosmetiques recentree sur les titres: bandeau "Titres" et affichage de la liste des titres vendus uniquement
- Descriptions des titres boutique retravaillees avec un ton plus concret, aligne sur chaque intitule
- Extension du catalogue de titres en vente avec de nouveaux titres payants (rares/epiques/legendaires, sans commons)

### Corrigé
- Suppression du bouton "Retirer le titre" sur la page profil

## [1.7.2] - 2026-03-27

### Corrigé
- Nettoyage visuel de la zone compte du profil (alignement des actions, reduction de l'espace vide en haut)
- Affichage du titre actif au format badge, coherent avec le rendu du leaderboard
- Alignement vertical des controles compte (mot de passe + changement pseudo) pour une lecture plus claire
- Affichage des titres possedes en liste ligne par ligne avec un rendu badge de type leaderboard, y compris pour les titres non selectionnes

## [1.7.1] - 2026-03-27

### Corrigé
- Ajustement de la zone haute du profil pour un rendu plus propre: avatar a gauche et actions compte alignees a droite
- Amelioration de la lisibilite du bloc "Mes Titres" avec la valeur de "Titre actuel" en blanc
- Harmonisation de la limite pseudo a 22 caracteres sur inscription, finalisation profil et changement de pseudo

## [1.7.0] - 2026-03-27

### Modifié
- Refonte structurante de la progression cosmetique: abandon des badges en affichage profil au profit d'un systeme centre sur les titres
- Mise en place d'un moteur de deblocage des titres gratuits par objectifs (`TitleUnlocker`), avec attribution automatique selon la progression joueur
- Ajout de deux sections dediees dans le profil: "Titres Communs Gratuits" et "Titres Prestige Gratuits"
- Ajout du changement de pseudo dans le profil (cooldown 1 fois par semaine) avec filtrage de pseudo reserve
- Masquage des objectifs des titres prestige tant qu'ils ne sont pas debloques
- Suppression des liens implicites sur les libelles de titres dans le profil; l'equipement passe par des actions explicites

## [1.6.1] - 2026-03-27

### Corrigé
- Erreur 500 du leaderboard au clic sur un joueur (requete agregee PostgreSQL corrigee)

## [1.6.0] - 2026-03-26

### Ajouté
- Système de badges débloquables par achievements (Voyageur, Persévérant, Combattant, Vétéran, Discipliné, Polymathe, etc.)
- Attributs rarity (rare/epic/legendary) et is_free sur le modèle Badge pour graduer les badges par prestige
- Titres libres débloquables gratuitement via completion d'achievements personnels (progression cohérente)
- Affichage du titre actif au profil utilisateur avec possibilité de changer parmi les titres possédés
- Gestion des titres multiples: un utilisateur peut changer activement son titre affiché

### Corrigé
- Apparence visuelle des noms au leaderboard (suppression de text-decoration: underline via text-decoration-none)
- Durcissement de la page Boutique pour eviter les erreurs 500 en presence de donnees partielles (rarete/nom) et en cas d'echec du calcul du defi hebdomadaire

## [1.5.0] - 2026-03-26

### Modifié
- Personnalisation des descriptions boutique: packs de coins adaptes au profil joueur et boosts contextualises selon la progression
- Coloration du texte des objets boutique selon la rarete pour une lecture plus immediate des paliers de valeur
- Enrichissement du bloc "Recommande pour toi" avec les descriptions personnalisees
- Ajout d'un defi boutique hebdomadaire (3 objectifs) avec recompense de coins recuperable une fois par semaine

### Corrigé
- La finalisation du profil ne bloque plus les actions Devise (notamment deconnexion), ce qui permet de revenir a l'ecran de connexion au lieu de rester coince sur la page de completion

## [1.4.0] - 2026-03-26

### Modifié
- Refonte complete des formulaires Devise (connexion, inscription, mot de passe oublie, confirmation, deblocage, edition compte) pour harmonisation avec le design HUD de l'application
- Uniformisation des boutons OAuth/liaisons Devise et des messages d'erreur avec le style visuel global
- Ajout d'un objectif quotidien sur le dashboard avec progression visuelle (quetes validees du jour)
- Refonte de la boutique avec navigation par onglets (Packs, Boosts, Cosmetiques)
- Ajout d'etats visuels explicites en boutique (Disponible, Possede, Equipe)
- Ajout d'un marquage "Best value" sur le pack coins le plus rentable
- Ajout d'un apercu profil dans la boutique (avatar, niveau global, titre actif)
- Ajout d'un bloc "Recommande pour toi" en boutique base sur le niveau global, la rarete cible et les objets deja possedes

### Corrigé
- Suppression des encarts de flash parasites (clés techniques de streak) qui s'affichaient comme de fausses erreurs sur le dashboard

## [1.3.3] - 2026-03-26

### Modifié
- Refonte de la page Quetes en mode "mission board" pour limiter l'effet liste longue
- Ajout de tuiles de synthese (missions visibles, suivies, categories) pour une lecture immediate
- Ajout de filtres rapides par categories via chips avec compteurs
- Separation claire entre "Tes quetes actives" et "Catalogue des missions"
- Transformation du catalogue en cartes de mission plus lisibles (description, XP, statut, mission du jour)
- Ajout d'onglets de difficulte (Easy, Medium, Hard) avec compteurs contextuels
- Ajout d'un tri rapide (mission du jour, rapide a faire, gros gain XP)
- Ajout d'un indicateur de streak sur les quetes actives pour visualiser la regularite
- Ajout d'un feedback visuel anime de streak apres validation d'une quete
- Ajout d'un bloc "Recommandees pour toi" base sur les categories de progression du joueur
- Optimisation des requetes de la page Quetes pour eviter les recherches utilisateur N+1
- Alignement du workflow CI GitHub Actions pour declencher sur `master` et `main`

## [1.3.2] - 2026-03-26

### Sécurité
- Mise à jour Rails de `8.0.5` vers `8.1.3` pour appliquer les correctifs de sécurité Active Storage
- Mise à jour de `faraday` vers `2.14.1` et `rexml` vers `3.4.4` suite à l'audit des vulnérabilités
- Audit `bundler-audit` relancé: plus aucune vulnérabilité gem détectée

### Modifié
- Remplacement de tous les specs `pending` (helpers/models/views) par des tests exécutables
- Exécution de la suite RSpec: `27 examples, 0 failures`

### Modifié
- Stabilisation du lockfile Ruby/Gems après mise à jour des dépendances critiques

## [1.3.1] - 2026-03-26

### Corrigé
- Sécurisation du flux d'achat Stripe: la confirmation applique désormais la logique de fulfillment centralisée au lieu de dépendre des données de session navigateur
- Correction du traitement webhook des packs de coins avec crédit effectif des coins utilisateur
- Renforcement de l'idempotence des achats Stripe via un index unique sur `purchases.transaction_id` (hors valeurs nulles)
- Blocage des confirmations Stripe incohérentes quand la session de checkout ne correspond pas à l'utilisateur connecté

### Sécurité
- Durcissement des redirections checkout Stripe avec validation explicite de l'URL et de l'hôte Stripe avant redirection externe
- Réduction de la surface de mass assignment admin (retrait de `admin` des paramètres autorisés de mise à jour utilisateur)

### Modifié
- Correction des specs request `user_weekly_quests` et `users` pour utiliser les routes réelles et l'authentification Devise
- Exécution de la suite RSpec: plus d'échec, uniquement des tests en attente

### Modifié
- Suppression de la route legacy `users/show` au profit de la route profil canonique
- Optimisation de la récupération des relations d'amis dans `FriendsController#index` (requêtes SQL directes sur IDs)
- Mise à jour de `.ruby-version` vers `3.2.10`

## [1.3.0] - 2026-03-26

### Ajouté
- Extension majeure du catalogue de quêtes: environ 20 quêtes par catégorie (Discipline, Physique, Savoir, Social, Défi)
- Enrichissement des quêtes avec des descriptions dédiées et des récompenses XP calibrées par difficulté

### Modifié
- Refactorisation de la seed des quêtes vers une structure par catégorie pour faciliter la maintenance et les évolutions futures

## [1.2.26] - 2026-03-26

### Modifié
- Verification responsive complete sur les pages Accueil, Quetes, Boutique et Classement
- Correction du conteneur du radar avec une classe dediee et hauteur adaptee sur mobile
- Ajout de retours a la ligne sur des blocs flex de la Boutique et du Dashboard pour eviter les debordements
- Amelioration du scroll horizontal tactile des tableaux sur mobile

## [1.2.25] - 2026-03-26

### Modifié
- Regroupement des itérations d'espacement de la Boutique (issues de 1.2.23 a 1.2.25)
- Harmonisation de l'espacement vertical entre les colonnes Boosts/Titres et la colonne gauche
- Suppression des lignes verticales de séparation pour un rendu plus léger
- Ajustement des espacements internes des sections HUD et des lignes de Boutique pour une meilleure respiration visuelle

## [1.2.24] - 2026-03-26

### Modifié
- Entree consolidee dans [1.2.25] pour eviter la repetition des memes ajustements d'espacement

## [1.2.23] - 2026-03-26

### Modifié
- Entree consolidee dans [1.2.25] pour eviter la repetition des memes ajustements d'espacement

## [1.2.22] - 2026-03-26

### Modifié
- Ajustement des espacements internes (padding/margin) pour aérer les sections HUD
- Suppression des coins arrondis restants sur les champs de recherche et sélecteurs
- Harmonisation des champs de formulaire avec la géométrie carrée du design global

## [1.2.21] - 2026-03-26

### Modifié
- Harmonisation de la page Boutique avec le même langage visuel HUD que le reste de l'interface
- Epuration de la Boutique avec sections plates et suppression du rendu "card dans card"
- Harmonisation de la page Classement (index et profil joueur) vers un conteneur principal unique avec sections internes

## [1.2.20] - 2026-03-26

### Modifié
- Amélioration de la lisibilité des chiffres du radar: labels décalés des points et contour de texte pour éviter le chevauchement
- Alignement visuel des cards sur la signature des boutons HUD (bordure, angles et glow cohérents)

## [1.2.19] - 2026-03-26

### Modifié
- Passage de l'accueil vers une structure plus fluide avec une seule enveloppe principale et des sections internes
- Passage de la page quêtes vers un conteneur unique (filtres + liste) pour réduire la sensation d'empilement
- Ajout de séparateurs visuels légers pour conserver la lisibilité sans multiplier les cartes

## [1.2.18] - 2026-03-26

### Modifié
- Le diagramme radar affiche désormais uniquement la valeur numérique de chaque point
- Suppression de l'affichage des valeurs d'échelle intermédiaires pour un rendu plus lisible

## [1.2.17] - 2026-03-26

### Modifié
- Simplification visuelle des listes de quêtes sur l'accueil et la page quêtes
- Suppression de l'effet "carte dans carte" au profit d'une présentation plus plate avec séparateurs
- Conservation du style HUD global avec une hiérarchie visuelle plus propre

## [1.2.16] - 2026-03-26

### Modifié
- Adaptation du design global pour l'aligner sur le style HUD bleu des boutons
- Harmonisation des cartes, tableaux, listes, formulaires et barres de progression avec la nouvelle direction visuelle
- Ajustement des couleurs du diagramme radar pour une cohérence complète avec l'interface

## [1.2.15] - 2026-03-26

### Modifié
- Affichage de l'échelle numérique du radar sur chaque axe (et non plus sur un seul)
- Conservation du mode sans toile d'araignée (grille interne toujours masquée)

## [1.2.14] - 2026-03-26

### Modifié
- Harmonisation des boutons HUD avec la palette globale charbon/ambre
- Adoucissement de la forme des boutons pour mieux s'intégrer aux composants de l'interface
- Réduction du contraste visuel des boutons afin de conserver une cohérence d'ensemble

## [1.2.13] - 2026-03-26

### Modifié
- Réaffichage de l'échelle numérique du diagramme radar
- Conservation d'un rendu sans effet toile d'araignée (grille et lignes angulaires désactivées)

## [1.2.12] - 2026-03-26

### Modifié
- Intégration d'un style bouton global inspiré de l'interface souhaitée (HUD futuriste)
- Uniformisation des variantes de boutons pour réduire encore le rendu Bootstrap
- Ajustement des effets hover/focus, bordures et lueurs pour une signature visuelle cohérente

## [1.2.11] - 2026-03-26

### Modifié
- Suppression du titre affiché au-dessus du diagramme radar pour une interface plus épurée
- Retrait du quadrillage intérieur du diagramme radar pour un rendu plus propre
- Renforcement du style personnalisé des boutons d'actions principales pour s'éloigner davantage du rendu Bootstrap

## [1.2.10] - 2026-03-26

### Modifié
- Refonte visuelle du thème global vers une palette charbon et ambre (abandon du rendu bleu/blanc)
- Modernisation des boutons avec un style moins Bootstrap classique et plus cohérent avec l'identité du jeu
- Refonte des barres de progression (piste + remplissage) pour un rendu plus premium et lisible
- Harmonisation des tableaux, listes, liens et champs de formulaire avec la nouvelle direction graphique

## [1.2.9] - 2026-03-26

### Modifié
- Harmonisation visuelle du classement avec un rendu sombre cohérent (suppression du fond blanc du tableau)
- Harmonisation du style de l'historique des quêtes dans le profil avec le thème global
- Refonte du style des boutons pour réduire l'aspect Bootstrap par défaut
- Traduction complète du changelog en français

## [1.2.8] - 2026-03-26

### Corrigé
- Imposer une seule quête hebdomadaire globale active en expirant les doublons actifs

### Modifié
- Refonte globale de l'interface vers un style immersif sombre de type "system"
- Mise à jour de l'identité de navigation et du contraste de l'interface pour une meilleure lisibilité
- Refonte des cartes, boutons, alertes et champs de formulaire pour s'aligner sur la nouvelle direction visuelle

## [1.2.7] - 2026-03-26

### Corrigé
- Les quêtes hebdomadaires sont désormais globales/partagées entre tous les utilisateurs au lieu d'être spécifiques à chaque utilisateur

### Modifié
- Le tableau de bord garantit maintenant une quête hebdomadaire globale active et relie chaque utilisateur à cette même quête

## [1.2.6] - 2026-03-26

### Ajouté
- Création automatique d'une quête hebdomadaire lorsqu'aucune n'est active

### Modifié
- Déplacement de "Quetes en cours" et "Quetes hebdomadaires" en haut du tableau de bord
- Intégration du graphique Kiviat directement dans le flux de page (sans carte dédiée)

## [1.2.5] - 2026-03-26

### Ajouté
- Ajout d'un graphique de progression Kiviat (radar) sur le tableau de bord par catégorie de quête

### Modifié
- Utilisation des données de statistiques embarquées du tableau de bord pour le graphique au lieu d'appels JSON supplémentaires
- Amélioration du rendu du graphique et des info-bulles pour la lisibilité des niveaux et de l'XP

## [1.2.4] - 2026-03-26

### Ajouté
- Ajout d'un bouton "Signaler un bug" sur le tableau de bord, relié aux GitHub Issues

### Modifié
- Suppression temporaire des offres d'avatars et de bundles dans la boutique
- Boutique recentrée sur l'achat de titres et les actions d'équipement

## [1.2.3] - 2026-03-26

### Ajouté
- Obligation de compléter le profil après la première inscription Google OAuth (pseudo + avatar requis)
- Ajout d'une page dédiée de complétion de profil pour les utilisateurs Google avant l'accès à l'application
- Ajout du drapeau `profile_completed` sur les utilisateurs pour suivre l'état d'onboarding
- Ajout d'un flux d'équipement des avatars cosmétiques possédés directement depuis la boutique
- Ajout du support d'avatar cosmétique actif sur l'utilisateur (`active_avatar_item_id`)
- Ajout de bundles cosmétiques par rareté (titre + avatar) avec prix en pièces réduit

### Corrigé
- Résolution des erreurs CSRF/authenticity OmniAuth pendant la phase de requête en production
- Garantie que le formulaire d'envoi OAuth contourne Turbo au niveau du formulaire
- Prévention des achats de bundles invalides ou falsifiés via validation serveur

### Modifié
- Suppression des messages flash d'authentification non essentiels (bruit success/info)
- Retour d'authentification recentré sur les avertissements/erreurs actionnables
- Refonte de la section Titres/Avatars de la boutique avec un cadrage de rareté plus fort et des états de possession
- Ajout d'actions directes "Equiper" pour les titres et avatars possédés afin de renforcer leur valeur cosmétique
- Affichage des avatars cosmétiques équipés dans le profil et le classement
- Mise en avant des économies sur bundles dans la boutique pour améliorer l'intention d'achat

## [1.2.2] - 2026-03-26
### Corrigé
- Correction de l'erreur 404 de route OmniAuth en passant la méthode du lien de GET à POST
- Vérification que le bouton OmniAuth initialise correctement la requête POST vers `/users/auth/google_oauth2`

### Modifié
- Suppression du fond en dégradé sur les pages de connexion et d'inscription
- Remplacement du dégradé violet (667eea → 764ba2) par un fond clair propre (`bg-light`)
- Affinage du style des pages d'authentification tout en conservant un design moderne par cartes et responsive
- Mise à jour du bouton Google OAuth avec `button_to`, méthode POST correcte et data-turbo: false

### Modifié
- Ajout du logo Google SVG sur le bouton d'authentification OAuth
- Amélioration de l'accessibilité des boutons avec une sémantique HTML correcte (button au lieu de anchor)
- Conservation des améliorations de mise en page par cartes, espacements et typographie de la v1.2.1
- Conservation de l'UI de sélection d'avatar et du style de formulaire sur la page d'inscription

## [1.2.1] - 2026-03-26
### Corrigé
- Correction de l'erreur CSRF Google OAuth en passant la méthode OmniAuth de POST à GET
- Vérification que la route OmniAuth utilise GET pour la phase initiale d'autorisation

### Modifié
- Refonte de la page de connexion (`/users/sign_in`) avec fond dégradé moderne et layout par cartes
- Refonte de la page d'inscription (`/users/sign_up`) avec UI de sélection d'avatar améliorée et cartes interactives
- Amélioration des espacements de formulaire et de la typographie pour une meilleure lisibilité
- Harmonisation du style des boutons OAuth sur toutes les pages d'authentification
- Ajout d'améliorations responsive pour mobile et desktop

### Modifié
- Ajout d'un séparateur avec "or" entre le formulaire et les options OAuth
- Implémentation d'un style Bootstrap 5 moderne avec fond dégradé (667eea → 764ba2)
- Ajout d'effets hover et de retours visuels sur les éléments interactifs
- Amélioration de la sélection d'avatar avec badges (Guerrier/Guerrière) et effets de transition

## [1.2.0] - 2026-03-26
### Ajouté
- Intégration Google OAuth via Devise OmniAuth
  - Les utilisateurs peuvent désormais s'inscrire et se connecter avec leur compte Google
  - Génération automatique du `pseudo` et attribution d'un avatar par défaut lors de la première connexion Google
  - Variables d'environnement requises: `GOOGLE_CLIENT_ID` et `GOOGLE_CLIENT_SECRET`
  - URL de callback OAuth: `/users/auth/google_oauth2/callback`
- Installation du skill Supabase Postgres Best Practices Agent
- Couverture de tests pour le flux de création utilisateur via Google OAuth

### Corrigé
- Utilisation de l'endpoint pooler Supabase IPv4 (`aws-1-eu-north-1.pooler.supabase.com:6543`) pour la compatibilité Heroku
- Résolution des problèmes de connectivité base de données en IPv6-only sur les dynos Heroku

## [1.1.2] - 2026-03-26
### Ajouté
- Endpoint webhook Stripe avec vérification de signature des événements de paiement
- Service idempotent de finalisation d'achat basé sur les IDs de transaction
- Emails de confirmation d'achat via Action Mailer

### Corrigé
- Mises à jour de dépendances de sécurité pour Rails, Devise, Nokogiri et Rack
- Correction des vulnérabilités signalées par Dependabot

## [1.1.1] - 2026-03-25
### Ajouté
- Support d'installation des skills Supabase Agent

### Modifié
- Amélioration de la documentation de configuration base de données

## [1.1.0] - 2026-03-25
### Ajouté
- Refactorisation complète du code avec des objets de service
- Centralisation de la logique d'attribution XP et badges via des classes de service
- Contraintes d'intégrité base de données et requêtes indexées
- Améliorations UI responsive pour mobile et desktop

### Corrigé
- Problèmes de duplication d'XP sur différents parcours de complétion de quêtes
- Problèmes de requêtes N+1 dans les contrôleurs leaderboard et friends
- Autorisation et idempotence du flux d'achat

## [1.0.0] - 2026-03-15
### Ajouté
- Initialisation de l'application Rails 8
- Authentification Devise avec confirmation email
- Systèmes de quêtes, quêtes utilisateur et quêtes hebdomadaires
- Mécaniques d'XP et de progression de niveau
- Système d'amis avec suivi des statuts
- Intégration de paiement Stripe
- Stockage d'images Cloudinary
- Tableau de bord admin pour la gestion des quêtes
- Pages de classement et de statistiques
