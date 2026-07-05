# MotivUp V3 — « Moins de bruit, plus de puissance »

Référence produit : Arise / Solo Leveling — on garde l'ADN chasseur de la V2.
Décisions validées le 05/07/2026 avec Arnaud.

> **État : V3 livrée (2026-07-06)** — Phases 0 à 3 implémentées, testées et déployées en production (Heroku, release v70). Fine-tuning visuel possible en itératif (retours/screenshots).

## Vision
La V2 a empilé les mécaniques (rangs, Système, saisons, factions, boutique,
passe). Le résultat : des écrans denses, une pile de cartes qui noie le geste
principal. La V3 ne retire aucune mécanique — elle **hiérarchise**. Un écran =
une intention claire. On passe d'un empilement de cartes à une interface
« HUD » calme et lisible, on resserre les quêtes autour de moins d'actions mais
plus fortes, et on enrichit la boutique de nouveaux objets désirables.

Prérequis technique : appliquer les migrations V2 en attente (voir
`## Phase 0`). Sans ça, le dashboard renvoie un 500.

## Phase 0 — Correctif dashboard 500 ⚠️ (à déployer)
- Cause : 5 migrations non appliquées (schema figé à `2026_07_05_120000`)
  alors que le dashboard interroge `system_quest_assignments`, `seasons`,
  `season_passes` → `PG::UndefinedTable` → 500.
- Fix : `bin/rails db:migrate` (dev) puis migration en prod via Kamal, et
  commit du `db/schema.rb` régénéré.
- Aucun code applicatif à changer — c'est un état de base non migré.

## Phase 1 — Redesign « moins de cards » (toute l'app) ✅ (implémenté — refonte « jeu mobile »)
Objectif : diviser par ~2 le nombre de conteneurs `surface-card` visibles et
faire ressortir une seule action prioritaire par écran.
- **Langage visuel unique** : une classe de section calme (`hud-panel`)
  remplace la multiplication de `surface-card`. Fond, bordure et ombre plus
  discrets ; espace blanc comme séparateur plutôt que des cartes empilées.
- **Dashboard (priorité)** :
  - Les bandeaux de notification (push, quickstart, bonus login, streak-up,
    suggestion boutique) fusionnés en **une seule zone d'alertes** empilables
    et discrètes, au lieu de 5 cartes pleine largeur.
  - Un **en-tête chasseur unifié** : pseudo + rang + streak + objectif du jour
    dans un seul bandeau, au lieu de 3 cartes séparées.
  - Le **Système** (quêtes du jour) devient le bloc central, seul mis en avant.
  - Factions, progression par catégorie, quêtes hebdo : regroupés en sections
    légères ou repliables, plus en cartes lourdes.
- **Boutique / Profil / Stats / Leaderboard** : même grammaire visuelle,
  grilles resserrées, moins de chrome par item.
- Respect `prefers-reduced-motion`, accessibilité (contrastes, focus) conservés.
- FR/EN inchangés (on réutilise les clés i18n existantes).

> **Réalisé — pass 1 (2026-07-06)** :
> - **Grammaire « moins de cards » app-wide** : `.surface-card` calmé (halo
>   interne retiré, ombre adoucie) → tous les écrans (boutique, profil, stats,
>   classement, dashboard) respirent davantage. Alias `.hud-panel` posé.
> - **Dashboard** : les 5 bandeaux empilés (push, quickstart, bonus login,
>   streak-up, suggestion boutique) fusionnés en **une seule zone d'alertes
>   discrète** (`.hud-alerts`) à liseré, au lieu de 5 cartes pleine largeur.
> - `prefers-reduced-motion` et accessibilité inchangés ; clés i18n réutilisées.
>
> _Reste pour un pass 2 (restructuration fine par écran)_ : en-tête chasseur
> unifié (pseudo+rang+streak+objectif), sections factions/progression
> repliables, grilles resserrées boutique/profil. À faire idéalement avec un
> retour visuel (screenshots ou extension Chrome connectée).

## Phase 2 — Quêtes : moins nombreuses, plus impactantes + nouveaux thèmes ✅ (implémenté)
- **Densité réduite** : le Système passe de 3-4 quêtes/jour à **2-3**, chacune
  au poids XP relevé (barème rehaussé, journée parfaite plus gratifiante).
  On garde la pondération vers les catégories faibles.
- **Nouveaux thèmes / catégories** : enrichir le catalogue Solo Leveling avec
  de nouveaux axes (ex. « Donjon » = défis physiques longs, « Éveil » =
  discipline mentale, « Guilde » = quêtes sociales). Migration de données
  respectant l'historique joueurs (`QuestCatalog` reste source unique).
- **Quêtes signature** : quelques quêtes E→S « boss » à fort XP pour donner un
  objectif d'aspiration, alignées sur les rangs.
- Tests sur `SystemQuestAssigner`, `SystemQuestBoard`, `QuestCatalog`.

> **Réalisé (2026-07-05)** :
> - Système ramené de 3-4 à **2-3 quêtes/jour** (`SystemQuestAssigner`).
> - Barème XP relevé (~+20 %) dans `QuestCatalog` ; journée parfaite plus
>   gratifiante (`SystemQuestBoard` : +35 % d'XP, 60 Fragments).
> - Chaque quête porte un **thème** (axe narratif : Éveil, Donjon, Codex,
>   Guilde, Faille) via une colonne `theme` — choix retenu plutôt que de
>   nouvelles `Category`, pour ne pas déstabiliser user_stats / factions /
>   badges / i18n. Promouvoir un thème en catégorie reste un suivi simple.
> - **Quêtes signature « boss »** E→S à XP doublé (`signature: true`), une
>   par catégorie, exclues du tirage quotidien (objectif d'aspiration).
> - Migration de données `QuestCatalog.sync!` préservant l'historique joueurs.
> - Tests : `spec/services/quest_catalog_spec.rb`,
>   `system_quest_assigner_spec.rb`, `system_quest_board_spec.rb`.

## Phase 3 — Boutique : nouveaux objets à acheter ✅ (implémenté)
- **Nouveaux cosmétiques** (crédits in-game) dans la lignée des 7 objets V2 :
  cadres, thèmes XP, cartes de rang inédits (ex. « Cadre Armée des Ombres »,
  « Thème Éveil National », « Carte Souverain »).
- **Nouveaux objets premium (€)** via Stripe (fulfillment webhook/succès déjà
  en place pour le passe) : objets exclusifs payants, cohérents avec le passe
  de saison, sans casser l'équilibre gameplay (cosmétique only côté premium).
- Intégration dans les **offres du jour** rotatives et, si pertinent, dans les
  paliers du passe de saison.
- Validation modèle `ShopItem` (types/raretés existants réutilisés), seeds,
  images Active Storage, tests d'achat.

> **Réalisé (2026-07-06)** :
> - **3 cosmétiques Orbes** (in-game) : Cadre Armée des Ombres (légendaire),
>   Thème XP Éveil National (épique), Carte de Visite Souverain (légendaire).
> - **3 objets premium € exclusifs** (Stripe, cosmétique only, sans avantage
>   gameplay) : Cadre de la Faille (4 €), Thème XP Couronne Suprême (3 €),
>   Carte de Visite Monarque (4 €).
> - Rendu visuel complet : mapping `CosmeticsHelper` + classes CSS animées,
>   `prefers-reduced-motion` respecté.
> - Intégration automatique aux **offres du jour** pour les objets Orbes
>   (`DailyShopDeals`) ; les objets premium restent hors remise.
> - Flux d'achat réutilisé tel quel (Orbes / Fragments / Stripe pour l'€).
> - Tests : `spec/helpers/cosmetics_helper_spec.rb` (mappings + non-régression
>   + garde-fou « premium = cosmétique only »).

## Principes (repris de la V2, toujours valables)
- Jamais punir la progression acquise (XP / rang / succès permanents).
- Chaque mécanique doit donner une raison de revenir demain.
- FR/EN systématique, tests sur chaque service de jeu.
- **Nouveau en V3** : une action prioritaire par écran. Si un élément ne sert
  pas cette action, il est replié, fusionné ou retiré.
