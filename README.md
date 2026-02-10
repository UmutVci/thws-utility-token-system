WalletConnect Schnellstart
--------------------------
- `pubspec.yaml` enthält bereits `walletconnect_flutter_v2`. Führe nach der Flutter-Einrichtung `flutter pub get` aus.
- Ersetze `YOUR_WALLETCONNECT_PROJECT_ID` in `lib/screens/wallet/wallet_screen.dart` durch deine WalletConnect-Cloud-`projectId`.
- iOS: Füge Schemas in `ios/Runner/Info.plist` unter `LSApplicationQueriesSchemes` hinzu (z. B. `wc`, `metamask`, `trust`).
- Android: Füge dieselben Schemas unter `<queries>` in `android/app/src/main/AndroidManifest.xml` hinzu (mit Intent-Filter, wenn du ein eigenes Schema verwendest).
- Testablauf: App starten → „Mit Wallet verbinden“ → Kopplung in der Wallet bestätigen (QR oder Deep Link) → Adresse erscheint → „Trennen“, um die Sitzung zu beenden.

MetaMask-Installation (DE)
--------------------------
- Lade MetaMask aus dem offiziellen App Store (iOS) oder Google Play Store (Android) herunter.
- Erstelle eine neue Wallet oder importiere eine bestehende mit deiner Seed-Phrase.
- Schalte biometrische Sperre bzw. PIN in MetaMask ein.
- Öffne anschließend die App, damit die Deep-Links funktionieren.
