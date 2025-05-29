# Cynapp - Application Mobile iOS

## Description

Cynapp est une application mobile iOS développée dans le cadre d'un projet de Bachelor 3. C'est une application de commerce électronique qui permet aux utilisateurs de parcourir et d'acheter des produits, de gérer leurs abonnements et de suivre leurs commandes.

## Fonctionnalités Principales

### Authentification

- Système de connexion/déconnexion
- Gestion des profils utilisateurs
- Sécurité renforcée avec gestion des mots de passe

### Catalogue de Produits

- Affichage des produits avec images et descriptions
- Système de recherche
- Catégorisation des produits

### Gestion des Commandes

- Panier d'achat
- Suivi des commandes
- Historique des transactions

### Abonnements

- Gestion des abonnements
- Prix mensuels et annuels
- Détails des abonnements actifs

### Interface Utilisateur

- Design moderne et intuitif
- Navigation par onglets
- Thème personnalisé avec couleurs de marque

## Architecture Technique

### Technologies Utilisées

- SwiftUI pour l'interface utilisateur
- Architecture MVVM (Model-View-ViewModel)
- Combine pour la gestion des flux de données
- WebKit pour l'intégration web

### Structure du Projet

```
Cynapp/
├── App/                 # Point d'entrée de l'application
├── Views/              # Composants d'interface utilisateur
├── ViewModels/         # Logique métier
├── Models/             # Modèles de données
├── Resources/          # Ressources (couleurs, etc.)
└── Assets.xcassets/    # Images et ressources graphiques
```

## Configuration Requise

- iOS 15.0 ou supérieur
- Xcode 13.0 ou supérieur
- Swift 5.5 ou supérieur

## Installation

1. Cloner le repository
2. Ouvrir le projet dans Xcode
3. Installer les dépendances si nécessaire
4. Compiler et exécuter le projet

## API

L'application se connecte à une API REST hébergée sur `https://b3-cyna-web.vercel.app/`

## Sécurité

- Authentification par token JWT
- Gestion sécurisée des mots de passe
- Protection des données utilisateur

## Licence

Projet scolaire, non destiné à une utilisation commerciale. Tous les droits réservés, aucune redistribution ou modifications autorisée sans accord préalable.
