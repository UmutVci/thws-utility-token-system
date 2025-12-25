import 'package:flutter/foundation.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

/// Lightweight WalletConnect v2 wrapper for connect/disconnect + address exposure.
class WalletConnectService extends ChangeNotifier {
  WalletConnectService({
    required String projectId,
    this.chains = const ['eip155:1'],
  }) : _projectId = projectId;

  final String _projectId;
  final List<String> chains;

  Web3App? _web3App;
  SessionData? _session;
  Uri? _pairingUri;
  bool _isConnecting = false;

  Future<void> init() async {
    if (_web3App != null) return;

    _web3App = await Web3App.createInstance(
      projectId: _projectId,
      relayUrl: 'wss://relay.walletconnect.com',
      metadata: const PairingMetadata(
        name: 'THWS Token',
        description: 'THWS Utility Token App',
        url: 'https://thws-token.local',
        icons: ['https://raw.githubusercontent.com/flutter/website/master/src/_assets/image/flutter-lockup-bg.jpg'],
      ),
    );

    _web3App!.onSessionConnect.subscribe((event) {
      _session = event.session;
      _pairingUri = null;
      _isConnecting = false;
      notifyListeners();
    });

    _web3App!.onSessionDelete.subscribe((_) {
      _session = null;
      _pairingUri = null;
      _isConnecting = false;
      notifyListeners();
    });
  }

  Future<Uri?> connect() async {
    if (_web3App == null) {
      await init();
    }

    _isConnecting = true;
    notifyListeners();

    final connectResponse = await _web3App!.connect(
      requiredNamespaces: {
        'eip155': RequiredNamespace(
          chains: chains,
          methods: const ['eth_sign', 'personal_sign', 'eth_sendTransaction'],
          events: const ['accountsChanged', 'chainChanged'],
        ),
      },
    );

    _pairingUri = connectResponse.uri;
    notifyListeners();

    // Wait for user approval; errors bubble up so caller can show a message.
    await connectResponse.session.future;

    return _pairingUri;
  }

  Future<void> disconnect() async {
    if (_web3App == null || _session == null) return;

    await _web3App!.disconnectSession(topic: _session!.topic);
    _session = null;
    _pairingUri = null;
    _isConnecting = false;
    notifyListeners();
  }

  String? get connectedAddress {
    final accounts = _session?.namespaces['eip155']?.accounts;
    if (accounts == null || accounts.isEmpty) return null;
    final raw = accounts.first;
    return raw.split(':').length == 3 ? raw.split(':').last : raw;
  }

  Uri? get pairingUri => _pairingUri;
  bool get isConnected => _session != null;
  bool get isConnecting => _isConnecting;
}
