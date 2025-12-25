import 'package:flutter/foundation.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

/// Lightweight WalletConnect v2 wrapper for connect/disconnect + address exposure.
class WalletConnectService extends ChangeNotifier {
  WalletConnectService({
    required String projectId,
    this.chains = const ['eip155:1'], // Ethereum mainnet
  }) : _projectId = projectId;

  final String _projectId;
  final List<String> chains;

  Web3App? _web3App;
  SessionData? _session;
  Uri? _pairingUri;
  bool _isConnecting = false;
  double? _nativeBalanceEth;

  Future<void> init() async {
    if (_web3App != null) return;

    try {
      debugPrint('[WC] init start');
      _web3App = await Web3App.createInstance(
        projectId: _projectId,
        relayUrl: 'wss://relay.walletconnect.com',
        metadata: const PairingMetadata(
          name: 'THWS Token',
          description: 'THWS Utility Token App',
          url: 'https://thws-token.local',
          icons: ['https://raw.githubusercontent.com/flutter/website/master/src/_assets/image/flutter-lockup-bg.jpg'],
          redirect: Redirect(
            native: 'thwstoken://wc',
            linkMode: true,
          ),
        ),
      );
      debugPrint('[WC] init created instance');

      _web3App!.onSessionConnect.subscribe((SessionConnect? event) {
        if (event != null) {
          debugPrint('[WC] onSessionConnect received topic=${event.session.topic}');
          _session = event.session;
          _pairingUri = null;
          _isConnecting = false;
          _refreshBalanceInternal();
          notifyListeners();
        }
      });

      _web3App!.onSessionEvent.subscribe((SessionEvent? event) {
        debugPrint('[WC] onSessionEvent: ${event?.name} ${event?.data}');
      });

      // Geri geldiğinde mevcut oturumu yükle (örn. uygulamayı yeniden açınca)
      final List<SessionData> cachedSessions = _web3App!.sessions.getAll();
      if (cachedSessions.isNotEmpty) {
        debugPrint('[WC] found cached session, reusing');
        _session = cachedSessions.first;
        _isConnecting = false;
        _pairingUri = null;
        await _refreshBalanceInternal();
        notifyListeners();
      }

      _web3App!.onSessionDelete.subscribe((SessionDelete? event) {
        _session = null;
        _pairingUri = null;
        _isConnecting = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Initialisierungsfehler: $e'); // Almanca: Başlatma hatası
    }
  }

  Future<Uri?> connect() async {
    try {
      debugPrint('[WC] connect called');
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

      // Session tamamlandığında state'i güncelle.
      _watchSessionFuture(connectResponse.session.future);

      return _pairingUri;
    } catch (e) {
      _isConnecting = false;
      _pairingUri = null;
      debugPrint('Verbindungsfehler: $e'); // Almanca: Bağlantı hatası
      notifyListeners();
      return null;
    }
  }

  Future<void> disconnect() async {
    if (_web3App == null || _session == null) return;

    try {
      await _web3App!.disconnectSession(
        topic: _session!.topic,
        reason: Errors.getSdkError(Errors.USER_DISCONNECTED),
      );
    } catch (e) {
      debugPrint('Fehler beim Trennen: $e'); // Almanca: Bağlantıyı kesme hatası
    } finally {
      _session = null;
      _pairingUri = null;
      _isConnecting = false;
      notifyListeners();
    }
  }

  Future<void> refreshBalance() => _refreshBalanceInternal();

  Future<void> resyncActiveSession() async {
    if (_web3App == null) return;
    final cachedSessions = _web3App!.sessions.getAll();
    if (cachedSessions.isEmpty) return;
    debugPrint('[WC] resyncActiveSession using cached session');
    _session = cachedSessions.first;
    _isConnecting = false;
    _pairingUri = null;
    await _refreshBalanceInternal();
    notifyListeners();
  }

  Future<void> _watchSessionFuture(Future<SessionData> future) async {
    try {
      final session = await future;
      debugPrint('[WC] session future resolved topic=${session.topic}');
      _session = session;
      _pairingUri = null;
      _isConnecting = false;
      await _refreshBalanceInternal();
      notifyListeners();
    } catch (e) {
      _isConnecting = false;
      notifyListeners();
      debugPrint('Session konnte nicht abgeschlossen werden: $e');
    }
  }

  Future<void> _refreshBalanceInternal() async {
    if (_web3App == null || _session == null) return;
    if (connectedAddress == null) return;

    try {
      final result = await _web3App!.request(
        topic: _session!.topic,
        chainId: chains.first,
        request: SessionRequestParams(
          method: 'eth_getBalance',
          params: [connectedAddress, 'latest'],
        ),
      );

      if (result is String && result.startsWith('0x')) {
        final wei = BigInt.parse(result.substring(2), radix: 16);
        _nativeBalanceEth = wei.toDouble() / 1e18;
        debugPrint('[WC] balance updated $_nativeBalanceEth');
        notifyListeners();
      } else {
        debugPrint('[WC] balance response unexpected: $result');
      }
    } catch (e) {
      debugPrint('Fehler beim Abrufen des Guthabens: $e');
    }
  }

  String? get connectedAddress {
    if (_session == null) return null;

    final accounts = _session?.namespaces['eip155']?.accounts;
    if (accounts == null || accounts.isEmpty) return null;

    final raw = accounts.first;
    return raw.split(':').last;
  }

  Uri? get pairingUri => _pairingUri;
  Uri? get metamaskDeepLink =>
      _pairingUri == null ? null : Uri.parse('metamask://wc?uri=${Uri.encodeComponent(_pairingUri.toString())}');
  bool get isConnected => _session != null;
  bool get isConnecting => _isConnecting;
  double? get nativeBalanceEth => _nativeBalanceEth;
  String? get formattedBalance => _nativeBalanceEth == null ? null : _nativeBalanceEth!.toStringAsFixed(4);
}
