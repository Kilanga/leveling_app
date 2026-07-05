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

## Phase 4 — Boutique attractive ✅ (implémenté)
- Offres rotatives : 3 objets en promo -25%, rotation quotidienne
  déterministe (seed = date), compte à rebours live affiché
- Préviews immersives : aperçu directement dans la carte (bouton modal
  « Aperçu profil » supprimé, aperçu inline ajouté aux titres),
  lueur animée par rareté (epic/legendary), respecte prefers-reduced-motion
- Passe de saison : 10 paliers à l'XP saisonnier (`SeasonPass`), piste
  gratuite + piste premium 10 € (Stripe, fulfillment webhook/succès),
  titre exclusif « Élu de la Saison N » au palier 10 premium
- Nouveaux objets : 7 cosmétiques (Cadre Monarque des Ombres, Thème XP
  Sang de Boss, Carte Rang S...) pour alimenter offres et passe

## Phase 5 — Landing page « Arise-like » ✅ (implémenté)
- Hero : « Solo Leveling pour ta vraie vie » + mockup statique du dashboard
  (quêtes du jour, rang B, barre de progression, journée parfaite)
- Sections : le Système, échelle des rangs E→S (seuils depuis `HunterRank`),
  saisons (chip saison en cours si dispo, lecture seule), boutique
- Preuve sociale : top 5 chasseurs par niveau total avec badge de rang
  + stats globales (joueurs, quêtes complétées/disponibles, axes),
  le tout en cache 10 min (`Rails.cache`) pour le trafic froid
- CTA unique « Commencer l'ascension » (hero + section finale),
  connexion reléguée en lien discret ; SEO/OG déjà en place
- FR/EN complet (bloc `welcome.index` réécrit), specs requests mises à jour

## Principes
- Jamais punir la progression acquise (XP/rang/succès permanents)
- Chaque mécanique doit donner une raison de revenir demain
- FR/EN systématique, tests sur chaque service de jeu
