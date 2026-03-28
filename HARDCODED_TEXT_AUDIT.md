# Leveling App - Hardcoded User-Facing Text Audit

## Executive Summary
This audit identifies ALL hardcoded user-facing text (labels, buttons, messages, headings, instructions) that should be moved to I18n translations. The application is currently in **French**, with some English text mixed in.

**Total Issues Found: 150+ hardcoded strings across 30+ files**

---

## 1. DEVISE AUTHENTICATION VIEWS

### `/app/views/devise/sessions/new.html.erb`
| Text | Type | Language |
|------|------|----------|
| "Connexion" | Page heading (h1) | FR |
| "Reprends ta progression la ou tu l'as laissee." | Subtitle | FR |
| "Email" | Form label | FR |
| "Mot de passe" | Form label | FR |
| "Se souvenir de moi" | Checkbox label | FR |
| "Se connecter" | Button text | FR |
| "ou" | Divider text | FR |

### `/app/views/devise/registrations/new.html.erb`
| Text | Type | Language |
|------|------|----------|
| "Inscription" | Page heading (h1) | FR |
| "Crée ton profil et choisis ton avatar de départ." | Subtitle | FR |
| "Email" | Form label | FR |
| "Pseudo (3-22 caractères)" | Form label | FR |
| "votre_pseudo" | Placeholder | FR |
| "Mot de passe" | Form label | FR |
| "Minimum X caractères" | Help text | FR |
| "Confirmer le mot de passe" | Form label | FR |
| "Code parrainage (optionnel)" | Form label | FR |
| "LVL1234" | Placeholder | FR |
| "Choisir votre avatar" | Form label | FR |
| "Guerrier" | Avatar badge | FR |
| "Guerrière" | Avatar badge | FR |
| "S'inscrire" | Button text | FR |
| "ou" | Divider text | FR |

### `/app/views/devise/passwords/new.html.erb`
| Text | Type | Language |
|------|------|----------|
| "Mot de passe oublié" | Page heading (h1) | FR |
| "Email" | Form label | FR |
| "votre@email.com" | Placeholder | FR |
| "Envoyer les instructions" | Button text | FR |

### `/app/views/devise/passwords/edit.html.erb`
| Text | Type | Language |
|------|------|----------|
| "Nouveau mot de passe" | Page heading (h1) | FR |
| "Nouveau mot de passe" | Form label | FR |
| "Confirmer le mot de passe" | Form label | FR |
| "Mettre à jour" | Button text | FR |

### `/app/views/devise/confirmations/new.html.erb`
| Text | Type | Language |
|------|------|----------|
| "Confirmation email" | Page heading (h1) | FR |
| "Renvoyer les instructions de confirmation." | Subtitle | FR |
| "Email" | Form label | FR |
| "votre@email.com" | Placeholder | FR |
| "Renvoyer les instructions" | Button text | FR |

### `/app/views/devise/unlocks/new.html.erb`
| Text | Type | Language |
|------|------|----------|
| "Déverrouiller le compte" | Page heading (h1) | FR |
| "Renvoyer les instructions de déverrouillage." | Subtitle | FR |
| "Email" | Form label | FR |
| "votre@email.com" | Placeholder | FR |
| "Renvoyer les instructions" | Button text | FR |

### `/app/views/devise/registrations/edit.html.erb`
| Text | Type | Language |
|------|------|----------|
| "Mets a jour tes informations de connexion." | Subtitle | FR |
| "En attente de confirmation pour:" | Alert text | FR |
| "Supprimer mon compte" | Button text | FR |
| "Confirmer la suppression ?" | Confirmation message | FR |

### `/app/views/devise/shared/_links.html.erb`
| Text | Type | Language |
|------|------|----------|
| "Se connecter" | Link text | FR |
| "Créer un compte" | Link text | FR |
| "Mot de passe oublié ?" | Link text | FR |
| "Renvoyer les instructions de confirmation" | Link text | FR |
| "Renvoyer les instructions de déverrouillage" | Link text | FR |
| "Continuer avec Google" | Button text | FR |
| "Continuer avec [provider]" | Button text | FR |

### `/app/views/devise/shared/_error_messages.html.erb`
- Uses `I18n.t("errors.messages.not_saved"...)` ✓ (GOOD - translated)

---

## 2. WELCOME PAGE

### `/app/views/welcome/index.html.erb`
| Text | Type | Language |
|------|------|----------|
| "Leveling \| Progression gamifiee" | Meta title | FR |
| "Leveling transforme ta progression personnelle en jeu: quetes, ligues hebdo, streaks et defis entre amis." | Meta description | FR |
| "Progression gamifiee" | Section kicker | FR |
| "Transforme ta progression en jeu competitif" | Main heading | FR |
| "Construis ta discipline avec des quetes courtes, grimpe dans les ligues hebdomadaires, et garde ton elan avec des rewards quotidiennes." | Subheading | FR |
| "Commencer maintenant" | Button | FR |
| "J'ai deja un compte" | Button | FR |
| "Invitation detectee: code..." | Alert text | FR |
| "joueurs motives" | Stat label | FR |
| "quetes disponibles" | Stat label | FR |
| "axes de progression" | Stat label | FR |
| "Pourquoi les joueurs restent" | Section heading | FR |
| "1. Action immediate" | Content heading | FR |
| "Tu choisis une quete..." | Content text | FR |
| "2. Competition saine" | Content heading | FR |
| "Tu compares ta semaine..." | Content text | FR |
| "3. Regularite recompensee" | Content heading | FR |
| "Streaks, coffre quotidien..." | Content text | FR |

---

## 3. DASHBOARD PAGE

### `/app/views/dashboard/index.html.erb`
| Text | Type | Language |
|------|------|----------|
| "Bienvenue, [pseudo]" | Page heading | FR |
| "Votre quartier general de progression." | Page subtitle | FR |
| "Boost XP actif jusqu'a [date]" | Badge text | FR |
| "Bonus connexion reclame: +X Fragments" | Status message | FR |
| "Serie actuelle: X jour(s)." | Help text | FR |
| "Connexion du jour" | Badge label | FR |
| "Streak hebdo: X semaine(s)" | Status text | FR |
| "Derniere validation: [date]" | Help text | FR |
| "Aucune validation cette semaine." | Help text | FR |
| "Voir la ligue dans Classement" | Link/button | FR |
| "Streak up: [quest title]" | Status message | FR |
| "Objectif du jour" | Section heading | FR |
| "Valider X quetes pour maintenir ton rythme." | Instruction text | FR |
| "Coffre quotidien: +X Fragments." | Help text | FR |
| "Coffre deja ouvert" | Badge | FR |
| "Ouvrir le coffre" | Button text | FR |
| "Territoires de guildes" | Section heading | FR |
| "Reset dans [time]." | Status text | FR |
| "Ta faction actuelle: [name]." | Status text | FR |
| "Changement verrouille jusqu'au prochain reset." | Help text | FR |
| "Choisis une faction pour commencer a capturer des territoires." | Instruction | FR |
| "Guilde gagnante (semaine precedente): [name]" | Section heading | FR |
| "Voir participants" | Button/link | FR |
| "Aucun participant enregistre." | Empty state | FR |
| "Faction dominante sur le cycle en cours: [name]" | Status text | FR |
| "Equipee" | Badge | FR |
| "Verrouille jusqu'au reset" | Button disabled label | FR |
| "Rejoindre" | Button | FR |
| "Marche noir: contrats du jour" | Section heading | FR |
| "Objectif: X/Y \| Prime: +Z Fragments" | Help text | FR |
| "Reclamer" | Button | FR |
| "Termine" | Badge | FR |
| "En cours" | Badge | FR |
| "Verrouille" | Badge | FR |
| "Accepter" | Button | FR |
| "Activite recente des amis" | Section heading | FR |
| "a complete une quete (+X XP)" | Status text | FR |
| "a valide sa quete hebdomadaire." | Status text | FR |
| "a ouvert le coffre quotidien (+X Fragments)" | Status text | FR |
| "vient d'accepter une demande d'ami." | Status text | FR |
| "Un ami" | Default user name | FR |
| "Aucune activite amie recente. Ajoute des amis pour remplir ce feed." | Empty state | FR |
| "Quetes en cours" | Section heading | FR |
| "Valider" | Button | FR |
| "Arreter" | Button | FR |
| "Quetes hebdomadaires" | Section heading | FR |
| "Voir toutes les quetes" | Link | FR |
| "Boutique" | Link | FR |
| "Signaler un bug" | Link | FR |
| "Progression des categories" | Section heading | FR |

---

## 4. QUESTS PAGE

### `/app/views/quests/index.html.erb`
| Text | Type | Language |
|------|------|----------|
| "Chasse aux quetes" | Page heading | FR |
| "Transforme ta to-do list en missions: choisis vite, suis l'avancement et grind ton XP." | Subtitle | FR |
| "Missions visibles" | Stat label | FR |
| "Missions suivies" | Stat label | FR |
| "Categories" | Stat label | FR |
| "Rechercher une quete ou un objectif..." | Search placeholder | FR |
| "Toutes les categories" | Default select option | FR |
| "Tri: mission du jour" | Select option | FR |
| "Tri: rapide a faire" | Select option | FR |
| "Tri: gros gain XP" | Select option | FR |
| "Lancer la recherche" | Button | FR |
| "Toutes difficultees" | Tab label | FR |
| "Easy" | Tab label | EN |
| "Medium" | Tab label | EN |
| "Hard" | Tab label | EN |
| "Toutes" | Category filter label | FR |
| "Recommandees pour toi" | Section heading | FR |
| "Elite" | Badge | EN |
| "Deja suivie" | Status badge | FR |
| "Ajouter" | Button | FR |
| "Pas encore de recommandations disponibles. Termine quelques missions pour personnaliser la suite." | Empty state | FR |
| "Tes quetes actives" | Section heading | FR |
| "Legend" | Streak label | EN |
| "En feu" | Streak label | FR |
| "Regulier" | Streak label | FR |
| "Debut" | Streak label | FR |
| "+X autres missions actives" | Help text | FR |
| "Aucune mission suivie. Lance-en une dans le catalogue." | Empty state | FR |
| "Catalogue des missions" | Section heading | FR |
| "Mission du jour" | Badge | FR |
| "Ne plus suivre" | Button | FR |
| "Suivre" | Button | FR |
| "Aucune mission ne correspond a ta recherche. Essaie un autre mot-cle." | Empty state | FR |

---

## 5. SHOP/PURCHASES PAGE

### `/app/views/purchases/new.html.erb`
| Text | Type | Language |
|------|------|----------|
| "Marche des aventuriers" | Page heading | FR |
| "Obtenez des ressources premium pour accelerer votre progression." | Subtitle | FR |
| "Tes Orbes premium:" | Label | FR |
| "Tes Fragments de progression:" | Label | FR |
| "Offre de bienvenue active" | Kicker text | FR |
| "Ton premier pack d'Orbes inclut +X% de bonus" | Section heading | FR |
| "Le bonus est deja calcule dans chaque carte pack: tu vois directement le total recu." | Help text | FR |
| "1er achat" | Badge | FR |
| "Packs" | Tab | FR |
| "Boosts" | Tab | FR |
| "Titres" | Tab | FR |
| "Cosmétiques" | Tab | FR |
| "Recompenses" | Tab | FR |
| "Packs d'Orbes" | Section heading | FR |
| "Bonus +X" | Badge | FR |
| "Best value" | Badge | EN |
| "X Orbes recus" | Stat text | FR |
| "(X + Y bonus Orbes)" | Details text | FR |
| "X Orbes / EUR" | Rate text | EN/FR |
| "Acheter X EUR" | Button | FR |
| "Boosts XP" | Section heading | FR |
| "Progression accéléree pendant [time]." | Help text | FR |
| "Activer - X EUR" | Button | FR |
| "Titres" | Section heading | FR |
| "Choisis un titre marquant pour imposer ton style dans le classement." | Instruction | FR |
| "Equipe maintenant" | Status text | FR |
| "Titre: [name]" | Badge | FR |
| "[Rarity]" | Badge label | EN/FR mix |
| "Common" | Rarity label | EN |
| "Rare" | Rarity label | EN |
| "Epic" | Rarity label | EN |
| "Legendary" | Rarity label | EN |
| "Equipe" | Status badge | FR |
| "Possede" | Status badge | FR |
| "Disponible" | Status badge | FR |
| "X Orbes" | Price label | FR |
| "X Fragments" | Price label | FR |
| "X EUR" | Price label | EN/FR |
| "Retirer" | Button | FR |
| "Equiper" | Button | FR |
| "Acheter" | Button | FR |
| "Indisponible" | Badge | FR |
| "Cosmétiques" | Section heading | FR |
| "Personnalise ton profil et tes barres de progression." | Instruction | FR |

---

## 6. LEADERBOARD PAGES

### `/app/views/leaderboard/index.html.erb`
| Text | Type | Language |
|------|------|----------|
| "Classement ligue hebdomadaire" | Page heading | FR |
| "Ligue actuelle: [name]" | Status text | FR |
| "Prochain reset ligue: [date]" | Status text | FR |
| "Dans [time]. Classement complet de ta ligue, avec mise a jour au chargement de la page." | Help text | FR |
| "Mouvement de ligue fige pour le moment: cohorte X/Y." | Warning text | FR |
| "Les promotions/relegations s'activent a partir de X joueurs." | Help text | FR |
| "Classement ligue hebdomadaire" | Section heading | FR |
| "Rang" | Table header | FR |
| "Avatar" | Table header | FR |
| "Joueur" | Table header | FR |
| "XP semaine" | Table header | FR |
| "Ligue" | Table header | FR |
| "Promotion projetee" | aria-label (alt text) | FR |
| "Montee" | Status label | FR |
| "Relegation projetee" | aria-label | FR |
| "Descente" | Status label | FR |
| "Maintien projete" | aria-label | FR |
| "Maintien" | Status label | FR |
| "Avatar de [pseudo]" | alt text | FR |
| "Toi" | Badge | FR |
| "Aucune donnee de ligue disponible." | Empty state | FR |

### `/app/views/leaderboard/show.html.erb` (Profile view)
| Text | Type | Language |
|------|------|----------|
| "Progression des categories" | Section heading | FR |
| "Aucune progression disponible." | Empty state | FR |
| "Aucune quete hebdomadaire visible." | Empty state | FR |
| "Aucune quete active en ce moment." | Empty state | FR |
| "Aucune donnee de progression a afficher." | Empty state | FR |
| "Aucune quete recente." | Empty state | FR |
| "Aucune quete populaire." | Empty state | FR |

---

## 7. FRIENDS PAGE

### `/app/views/friends/index.html.erb`
| Text | Type | Language |
|------|------|----------|
| "Liste de mes amis" | Page heading | FR |
| "Amis actifs" | Section heading | FR |
| "Lancer un defi 48h" | Button | FR |
| "Retirer" | Button | FR |
| "Defis actifs" | Section heading | FR |
| "Aucun defi actif." | Empty state | FR |
| "Parrainage" | Section heading | FR |
| "Demandes recues" | Section heading | FR |
| "Accepter" | Button | FR |
| "Refuser" | Button | FR |
| "Demandes envoyees" | Section heading | FR |
| "Annuler" | Button | FR |
| "Rechercher un ami" | Section heading | FR |
| "Rechercher par pseudo" | Label | FR |
| "Pseudo du joueur" | Placeholder | FR |
| "Rechercher" | Button | FR |
| "Resultats" | Section heading | FR |
| "Envoyer une demande" | Button | FR |
| "Quetes les plus realisees par mes amis" | Section heading | FR |
| "Dernieres quetes realisees par mes amis" | Section heading | FR |

### `/app/views/friends/search.html.erb`
| Text | Type | Language |
|------|------|----------|
| "Rechercher un ami" | Page heading | FR |
| "Rechercher par pseudo :" | Form label | FR |
| "Rechercher" | Button | FR |
| "Résultats :" | Section heading | FR |
| "Ajouter en ami" | Button | FR |

---

## 8. USER PROFILE/ACCOUNT PAGES

### `/app/views/users/show.html.erb`
| Text | Type | Language |
|------|------|----------|
| "Profil de [pseudo]" | Page heading | FR |
| "Quetes completees" | Card title | FR |
| "XP cette semaine" | Card title | FR |
| "Streak hebdo" | Card title | FR |
| "Avatar de [pseudo]" | alt text | FR |
| "Modifier mon mot de passe" | Button | FR |
| "Nouveau pseudo" | Placeholder | FR |
| "Changer mon pseudo" | Button | FR |
| "Prochain changement de pseudo possible le [date]." | Help text | FR |
| "Le pseudo peut etre modifie une fois par semaine." | Help text | FR |
| "Cosmétiques" | Section heading | FR |
| "Cadre de Profil" | Subsection heading | FR |
| "Encadrement autour de ton pseudo au classement." | Description | FR |
| "Aucun cadre actif" | Badge | FR |
| "Actif" | Badge | FR |
| "Thème de Barre XP" | Subsection heading | FR |
| "Couleurs et style de ta barre de progression." | Description | FR |
| "Thème par défaut" | Badge | FR |
| "Carte de Visite" | Subsection heading | FR |
| "Affichée dans ton profil et visible par les autres joueurs." | Description | FR |
| "Aucune carte active" | Badge | FR |
| "Ton message perso (max 100 caracteres)" | Placeholder | FR |
| "Mettre a jour" | Button | FR |
| "Mes Titres" | Section heading | FR |
| "Titre actuel:" | Label | FR |
| "Aucun titre actif" | Status text | FR |
| "Aucun titre disponible pour le moment. Gagnez-les en boutique!" | Empty state | FR |
| "Titres Communs Gratuits" | Section heading | FR |
| "Objectif: [text]" | Help text | FR |
| "Debloque" | Badge | FR |
| "Bloque" | Badge | FR |
| "Objectif non atteint" | Help text | FR |

### `/app/views/users/complete_profile.html.erb`
| Text | Type | Language |
|------|------|----------|
| "Finaliser votre profil" | Page heading | FR |
| "Choisissez votre pseudo et votre avatar pour commencer l'aventure." | Subtitle | FR |
| "Pseudo (3-22 caractères)" | Form label | FR |
| "votre_pseudo" | Placeholder | FR |
| "Choisir votre avatar" | Form label | FR |
| "Avatar Guerrier" | alt text | FR |
| "Guerrier" | Avatar badge | FR |
| "Avatar Guerrière" | alt text | FR |
| "Guerrière" | Avatar badge | FR |
| "Commencer l'aventure" | Button | FR |

---

## 9. NOTIFICATIONS PAGE

### `/app/views/notifications/index.html.erb`
| Text | Type | Language |
|------|------|----------|
| "Notifications" | Page heading | FR |
| "Retrouve les rappels utiles, defis et activites sociales." | Page subtitle | FR |
| "Tout marquer lu" | Button | FR |
| "Lue" | Badge | FR |
| "Ouvrir" | Button | FR |
| "Aucune notification pour le moment." | Empty state | FR |

---

## 10. ADMIN PAGES

### `/app/views/admin/users/index.html.erb`
| Text | Type | Language |
|------|------|----------|
| "Gestion des utilisateurs" | Page heading | FR |
| "Modifier" | Link/button | FR |

### `/app/views/admin/users/edit.html.erb`
| Text | Type | Language |
|------|------|----------|
| "Modifier l'utilisateur" | Page heading | FR |
| "XP" | Form label | FR |
| "Orbes" | Form label | FR |
| "Fragments" | Form label | FR |
| "Admin ?" | Form label | FR |
| "Mettre à jour" | Button | FR |

### `/app/views/admin/quests/index.html.erb`
| Text | Type | Language |
|------|------|----------|
| "Gestion des quêtes" | Page heading | FR |
| "Modifier" | Link/button | FR |
| "Supprimer cette quête ?" | Confirmation message | FR |

### `/app/views/admin/analytics/index.html.erb`
| Text | Type | Language |
|------|------|----------|
| "Analytics Produit" | Page heading | FR |
| "Top events (7 jours)" | Section heading | FR |

---

## 11. CONTROLLER FLASH MESSAGES

All of the following hardcoded strings in controllers should be moved to I18n:

### `/app/controllers/friend_challenges_controller.rb`
| Text | Flash type |
|------|------------|
| "Defi lance pour 48h." | notice |

### `/app/controllers/purchases_controller.rb`
| Text | Flash type |
|------|------------|
| "+X Fragments recuperes via le defi boutique !" | notice |
| "Achat confirme !" | notice |
| "Objet débloqué avec tes Fragments !" | notice |
| "Objet acheté avec succès !" | notice (default) |

### `/app/controllers/dashboard_controller.rb`
| Text | Flash type |
|------|------------|
| "Coffre quotidien ouvert: +X Fragments." | notice |

### `/app/controllers/user_daily_contracts_controller.rb`
| Text | Flash type |
|------|------------|
| "Prime recuperee: +X Fragments." | notice |

### `/app/controllers/user_weekly_quests_controller.rb`
| Text | Flash type |
|------|------------|
| "Quete completee ! XP ajoute : X" | success |
| "Cette quête hebdomadaire est déjà validée." | alert |

### `/app/controllers/notifications_controller.rb`
| Text | Flash type |
|------|------------|
| "Notifications marquees comme lues." | notice |

### `/app/controllers/user_quests_controller.rb`
| Text | Flash type |
|------|------------|
| "Quête ajoutée avec succès !" | notice |
| "Cette quete n'est pas encore disponible." | alert |
| "Quête réactivée avec succès !" | notice |
| "Tu suis déjà cette quête." | alert |
| "Quête retirée avec succès." | notice |
| "Impossible de retirer la quête." | alert |
| "Quete completee ! XP ajoute : X.Y" | notice |
| "Quête supprimée de votre liste." | notice |

### `/app/controllers/users_controller.rb`
| Text | Flash type |
|------|------------|
| "Ce pseudo est deja le tien." | notice |
| "Pseudo mis a jour." | notice |
| "Titre activé." | notice |
| "Titre retiré." | notice |
| "Avatar equipe avec succes." | notice |
| "Cosmetic active avec succes." | notice |
| "Texte de carte mise a jour." | notice |

### `/app/controllers/friends_controller.rb`
| Text | Flash type |
|------|------------|
| "Demande d'ami envoyee !" | notice |
| "Amitié acceptée !" | notice |
| "Aucune demande trouvée." | alert |
| "Demande refusée." | notice |
| "Amitié supprimée avec succès." | notice |
| "Impossible de supprimer cet ami." | alert |

### `/app/controllers/daily_contracts_controller.rb`
| Text | Flash type |
|------|------------|
| "Contrat accepte." | notice |

### `/app/controllers/factions_controller.rb`
| Text | Flash type |
|------|------------|
| "Tu fais deja partie de [faction]." | notice |
| "Faction rejointe: [faction]." | notice |

### `/app/controllers/admin/users_controller.rb`
| Text | Flash type |
|------|------------|
| "Utilisateur mis à jour." | notice |

### `/app/controllers/admin/quests_controller.rb`
| Text | Flash type |
|------|------------|
| "Quête créée avec succès." | notice |
| "Quête mise à jour." | notice |

---

## 12. VARIOUS HARDCODED STRINGS IN VIEWS

### Meta Tags / Page Headers
- `content_for :title` - Multiple pages have hardcoded French titles
- `content_for :meta_description` - Multiple pages have hardcoded French descriptions

### Alert/Empty State Messages
- "Aucune [item] pour le moment." - Multiple occurrences
- "Aucune [item] disponible." - Multiple occurrences
- "Aucune [item] visible." - Multiple occurrences

### Form-Related Text
- Placeholder text: "votre@email.com", "votre_pseudo", etc.
- Help text: "Minimum X caractères", etc.
- Validation messages

### Badge/Status Labels
- "Equipee", "Active", "En cours", "Termine", etc.
- Rarity levels: "Common", "Rare", "Epic", "Legendary"
- Currency labels: "Orbes", "Fragments"

---

## 13. MIXED LANGUAGE ISSUES

Some components mix English and French:
- Select options: "Easy", "Medium", "Hard" (EN) alongside French labels
- Badges: English rarity labels ("Common", "Rare") in French context
- Currency: "EUR" (EN/EN) mixed with French descriptions

---

## 14. CURRENTLY TRANSLATED (GOOD EXAMPLES)

The following are already properly using I18n:
- `I18n.t("currency.paid", count: amount.to_i)` in ApplicationController
- `I18n.t("currency.free", count: amount.to_i)` in ApplicationController
- `I18n.t("errors.messages.not_saved", count: ..., resource: ...)` in error messages

---

## RECOMMENDATIONS

1. **Create comprehensive French (.fr.yml) and English (.en.yml) locale files** with all strings from this audit
2. **Replace all hardcoded strings** with `t()` or `I18n.t()` calls
3. **Organize translation keys** by domain:
   - `auth.*` - Devise auth pages
   - `dashboard.*` - Dashboard page
   - `quests.*` - Quest-related
   - `shop.*` - Shop/purchases
   - `leaderboard.*` - Leaderboard
   - `friends.*` - Friends features
   - `users.*` - User profile
   - `notifications.*` - Notifications
   - `admin.*` - Admin panels
   - `flash.*` or `messages.*` - Flash messages
4. **Add pluralization rules** for French where applicable
5. **Consider date/time formatting** per locale
6. **Test both languages** across all user flows

---

## FILES TO UPDATE

**Priority 1 (Devise/Auth):**
- app/views/devise/sessions/new.html.erb
- app/views/devise/registrations/new.html.erb
- app/views/devise/registrations/edit.html.erb
- app/views/devise/passwords/new.html.erb
- app/views/devise/passwords/edit.html.erb
- app/views/devise/confirmations/new.html.erb
- app/views/devise/unlocks/new.html.erb
- app/views/devise/shared/_links.html.erb

**Priority 2 (Main Pages):**
- app/views/welcome/index.html.erb
- app/views/dashboard/index.html.erb
- app/views/quests/index.html.erb
- app/views/purchases/new.html.erb
- app/views/leaderboard/index.html.erb
- app/views/leaderboard/show.html.erb
- app/views/friends/index.html.erb
- app/views/friends/search.html.erb

**Priority 3 (User Account):**
- app/views/users/show.html.erb
- app/views/users/complete_profile.html.erb
- app/views/notifications/index.html.erb

**Priority 4 (Controllers):**
- All controller files with `notice:` or `alert:` messages (see section 11)

**Priority 5 (Admin):**
- app/views/admin/users/*.html.erb
- app/views/admin/quests/*.html.erb
- app/views/admin/analytics/index.html.erb

---

## TOTAL SUMMARY

- **Total Hardcoded User-Facing Text:** 150+ instances
- **Files Affected:** 30+ view files + 12+ controller files
- **Languages:** Primarily French with some English
- **Estimated Translation Keys Needed:** 200+
