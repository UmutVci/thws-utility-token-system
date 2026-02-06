import 'wallet_connect_service.dart';

// Shared WalletConnect instance to avoid multiple sessions.
final WalletConnectService walletConnectService =
    WalletConnectService(projectId: '8bcdb71c4952a4b75a62c7f38ba5eb55');
