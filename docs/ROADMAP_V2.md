# MotivUp V2 — « Deviens le chasseur de ta propre vie »

Référence produit : Arise (fitness gamifiée façon Solo Leveling).
Décisions validées le 05/07/2026 avec Arnaud.

## Vision
Le joueur est un chasseur. Son rang (E→S) est son identité permanente.
Chaque jour, le Système lui assigne des quêtes. Chaque saison (6 semaines),
il prouve sa valeur pour des récompenses exclusives.

## Phase 1 — Rangs de chasseur E→S ✅ (implémenté)
- Rang permanent calculé depuis le niveau total : E(0) D(10) C(25) B(50) A(85) S(130)
- Affiché : navbar, profil, classement, accueil joueur public, dashboard
- Barre de progression vers le rang suivant sur le profil
- Service : `HunterRank`

## Phase 2 — Le Système : quêtes quotidiennes imposées ✅ (implémenté)
- À minuit (recurring Solid Queue), 3-4 quêtes du jour assignées par joueur,
  pondérées vers ses catégories faibles (user_stats les plus bas)
  → `SystemQuestAssigner` + filet de sécurité au chargement du dashboard
- Bonus « journée parfaite » : +25% XP (catégorie la plus faible) et
  +40 Fragments si tout est complété → `SystemQuestBoard`
- Malus doux : rater 2 jours de suite gèle la progression du contrat hebdo
  (pas de perte d'XP — on punit jamais la progression acquise) ;
  compléter une quête du jour lève le gel
- Choix retenu : nouvelle table `system_quest_assignments` (assignation
  par joueur/jour) plutôt qu'évolution des daily_contracts, qui ne sont
  plus proposés sur le dashboard
- Réécriture du catalogue : ton Solo Leveling, difficulté E→S alignée sur
  les rangs, XP rééquilibré par difficulté → `QuestCatalog` (source unique
  seeds + migration de données, historique joueurs préservé)

## Phase 3 — Saisons (6 semaines) ✅ (implémenté)
- Modèle Season (starts_on, ends_on, name, number) + noms thématiques
  Solo Leveling, saisons enchaînées sans trou → `SeasonManager`
- Classement saisonnier : ledger `user_seasons` alimenté par XpAwarder
  (exact, et réutilisable pour le passe de saison Phase 4)
- Fin de saison (recurring quotidien) : badge exclusif top 10%
  (user_badges réveillée) + titre unique « Souverain de la Saison N »
  pour le top 3, notifications in-app
- Reset : ligues hebdo uniquement. XP, rangs et succès sont permanents.

## Phase 4 — Boutique attractive
- Offres rotatives : 3 objets en promo -20/30%, rotation quotidienne
  déterministe (seed = date), compte à rebours affiché
- Préviews immersives : aperçu du cosmétique directement dans la carte
  (plus de clic « Aperçu profil »), lueur animée par rareté (epic/legendary)
- Passe de saison (dépend Phase 3) : piste gratuite + piste premium (Stripe),
  paliers débloqués à l'XP saisonnier
- Nouveaux objets à acheter : élargir le catalogue (cosmétiques, cadres,
  thèmes XP, titres...) pour alimenter les offres rotatives et le passe

## Phase 5 — Landing page « Arise-like »
- Hero : « Solo Leveling pour ta vraie vie » + mockup du dashboard
- Sections : le Système (quêtes du jour), les rangs, les saisons, la boutique
- Preuve sociale : rangs des meilleurs chasseurs, stats globales
- CTA unique « Commencer l'ascension » ; SEO/OG déjà en place

## Principes
- Jamais punir la progression acquise (XP/rang/succès permanents)
- Chaque mécanique doit donner une raison de revenir demain
- FR/EN systématique, tests sur chaque service de jeu
