# BadWallet — Application Mobile Flutter

Application mobile **Consumer** de portefeuille numérique, développée dans le cadre de l'examen Flutter L3 S2 2026.

## Concept

BadWallet permet aux utilisateurs de gérer leur portefeuille depuis leur smartphone, à l'image de Wave ou Orange Money. Elle consomme les endpoints de la **BadWallet API** exposée sur `http://localhost:8080`.

## Fonctionnalités

- **Authentification** — Connexion par numéro de téléphone
- **Tableau de bord** — Solde en temps réel, masquable, 5 dernières transactions
- **Transfert d'argent** — Envoi vers un autre compte BadWallet
- **Paiement de factures** — SENELEC, WOYAFAL, ISM, RAPIDO (sélection multiple)
- **Historique** — Liste complète des transactions avec codes couleur

## Architecture

Structure **Feature-First** avec **Provider** comme gestionnaire d'état.

```
lib/
├── core/           # Thème, Constantes, Services HTTP
├── features/
│   ├── auth/       # Authentification
│   ├── dashboard/  # Tableau de bord
│   ├── transfers/  # Transferts
│   ├── bills/      # Factures
│   └── history/    # Historique
├── models/         # Wallet, Transaction, Facture
└── main.dart
```

## Technologies

| Package | Usage |
|---|---|
| `provider` | State management |
| `http` | Requêtes API |
| `intl` | Formatage monnaie (XOF) |
| `google_fonts` | Typographie Poppins |
| `shared_preferences` | Stockage local |
| `device_preview` | Aperçu multi-device |
| `flutter_launcher_icons` | Icône app personnalisée |

## Lancer le projet

```bash
flutter pub get
flutter run
```

## Générer l'APK

```bash
flutter build apk --release
# APK : build/app/outputs/flutter-apk/app-release.apk
```

## API Endpoints utilisés

| Méthode | Endpoint | Usage |
|---|---|---|
| `GET` | `/api/wallets/{phone}` | Informations wallet |
| `GET` | `/api/wallets/{phone}/balance` | Solde |
| `GET` | `/api/wallets/{phone}/transactions` | Historique |
| `POST` | `/api/wallets/transfer` | Transfert |
| `POST` | `/api/wallets/pay-factures` | Paiement factures |
