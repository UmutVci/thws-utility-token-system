WalletConnect quick setup
------------------------
- `pubspec.yaml` already includes `walletconnect_flutter_v2`. Run `flutter pub get` after setting up Flutter.
- Replace `YOUR_WALLETCONNECT_PROJECT_ID` in `lib/screens/wallet/wallet_screen.dart` with your WalletConnect Cloud projectId.
- iOS: add schemes to `ios/Runner/Info.plist` under `LSApplicationQueriesSchemes` (e.g. `wc`, `metamask`, `trust`).
- Android: add the same schemes to `<queries>` in `android/app/src/main/AndroidManifest.xml` (intent filter if you use a custom scheme).
- Test flow: launch app → “Cüzdana Bağlan” → approve pairing in wallet (QR or deep link) → address appears → “Disconnect” to drop session.

