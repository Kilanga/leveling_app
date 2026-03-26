# Journal des modifications

Toutes les modifications notables de ce projet sont documentées dans ce fichier.

Le format suit [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
et ce projet respecte [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Non publié]

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

### Améliorations UI
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

### Améliorations UI
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
