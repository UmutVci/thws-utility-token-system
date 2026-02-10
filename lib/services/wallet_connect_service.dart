import 'dart:async';

import 'package:flutter/foundation.dart';

import '../config/contracts.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

/// Schlanker WalletConnect-v2-Wrapper für Verbinden/Trennen und Adresszugriff.
class WalletConnectService extends ChangeNotifier {
  WalletConnectService({
    required String projectId,
    this.chains = const ['eip155:11155111'], // Sepolia-Netzwerk
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
          description: 'THWS Token-App',
          url: 'https://www.thws.de',
          icons: [
            'https://www.thws.de/fileadmin/public/Images/favicon/apple-touch-icon.png'
          ],
          redirect: Redirect(
            native: 'thwstoken://wc',
            linkMode: true,
          ),
        ),
      );
      debugPrint('[WC] init created instance');

      _web3App!.onSessionConnect.subscribe((SessionConnect? event) {
        if (event != null) {
          debugPrint(
              '[WC] onSessionConnect received topic=${event.session.topic}');
          _session = event.session;
          _pairingUri = null;
          _isConnecting = false;
          ensureSepoliaChain();
          _refreshBalanceInternal();
          notifyListeners();
        }
      });

      _web3App!.onSessionEvent.subscribe((SessionEvent? event) {
        debugPrint('[WC] onSessionEvent: ${event?.name} ${event?.data}');
      });

      // Vorhandene Sitzung wiederherstellen (z. B. nach erneutem App-Start)
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
      debugPrint('Initialisierungsfehler: $e');
    }
  }

  Future<Uri?> connect() async {
    try {
      debugPrint('[WC] connect called');
      if (_web3App == null) {
        await init();
      }
      if (_session != null && connectedAddress != null) {
        _isConnecting = false;
        _pairingUri = null;
        notifyListeners();
        return null;
      }
      if (_isConnecting) {
        return _pairingUri;
      }

      _isConnecting = true;
      notifyListeners();

      final connectResponse = await _web3App!.connect(
        requiredNamespaces: {
          'eip155': RequiredNamespace(
            chains: chains,
            methods: const [
              'eth_sign',
              'personal_sign',
              'eth_sendTransaction',
              'eth_getBalance',
              'wallet_switchEthereumChain',
              'wallet_addEthereumChain'
            ],
            events: const ['accountsChanged', 'chainChanged'],
          ),
        },
      );

      _pairingUri = connectResponse.uri;
      notifyListeners();

      // Status aktualisieren, sobald die Sitzung abgeschlossen ist.
      _watchSessionFuture(connectResponse.session.future);

      return _pairingUri;
    } catch (e) {
      _isConnecting = false;
      _pairingUri = null;
      debugPrint('Verbindungsfehler: $e');
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
      debugPrint('Fehler beim Trennen: $e');
    } finally {
      _session = null;
      _pairingUri = null;
      _isConnecting = false;
      notifyListeners();
    }
  }

  Future<String?> sendTransaction({
    required String to,
    required String data,
    String value = '0x0',
  }) async {
    if (_web3App == null || _session == null) {
      throw Exception('Wallet ist nicht verbunden.');
    }
    final from = connectedAddress;
    if (from == null) {
      throw Exception('Keine Wallet-Adresse verfügbar.');
    }

    final result = await _web3App!.request(
      topic: _session!.topic,
      chainId: chains.first,
      request: SessionRequestParams(
        method: 'eth_sendTransaction',
        params: [
          {
            'from': from,
            'to': to,
            'data': data,
            'value': value,
          }
        ],
      ),
    );

    if (result is String) return result;
    return null;
  }

  Future<void> refreshBalance() => _refreshBalanceInternal();

  Future<void> waitForTransactionSuccess(
    String txHash, {
    Duration timeout = const Duration(minutes: 2),
    Duration pollInterval = const Duration(seconds: 2),
  }) async {
    if (_web3App == null || _session == null) {
      throw Exception('Wallet ist nicht verbunden.');
    }

    final startedAt = DateTime.now();
    while (DateTime.now().difference(startedAt) < timeout) {
      final receipt = await _web3App!.request(
        topic: _session!.topic,
        chainId: chains.first,
        request: SessionRequestParams(
          method: 'eth_getTransactionReceipt',
          params: [txHash],
        ),
      );

      if (receipt is Map<String, dynamic>) {
        final status = '${receipt['status'] ?? ''}'.toLowerCase();
        if (status == '0x1' || status == '1') return;
        if (status == '0x0' || status == '0') {
          throw Exception('Transaktion wurde auf der Chain verworfen.');
        }
      } else if (receipt != null) {
        final status = '$receipt'.toLowerCase();
        if (status.contains('0x1')) return;
      }

      await Future.delayed(pollInterval);
    }

    throw TimeoutException(
      'Transaktionsbestätigung hat zu lange gedauert.',
      timeout,
    );
  }

  Future<void> ensureSepoliaChain() async {
    if (_web3App == null || _session == null) return;
    try {
      await _web3App!.request(
        topic: _session!.topic,
        chainId: chains.first,
        request: const SessionRequestParams(
          method: 'wallet_switchEthereumChain',
          params: [
            {'chainId': '0xaa36a7'}
          ],
        ),
      );
    } catch (_) {
      await _web3App!.request(
        topic: _session!.topic,
        chainId: chains.first,
        request: SessionRequestParams(
          method: 'wallet_addEthereumChain',
          params: [
            {
              'chainId': '0xaa36a7',
              'chainName': 'Sepolia',
              'nativeCurrency': {
                'name': 'Sepolia ETH',
                'symbol': 'ETH',
                'decimals': 18,
              },
              'rpcUrls': [ContractsConfig.rpcUrl],
              'blockExplorerUrls': ['https://sepolia.etherscan.io'],
            }
          ],
        ),
      );
    }
  }

  Future<void> resyncActiveSession() async {
    if (_web3App == null) return;
    final cachedSessions = _web3App!.sessions.getAll();
    if (cachedSessions.isEmpty) return;
    debugPrint('[WC] resyncActiveSession using cached session');
    final next = cachedSessions.first;
    // Sicherstellen, dass die zwischengespeicherte Sitzung Sepolia unterstützt.
    final accounts = next.namespaces['eip155']?.accounts ?? const [];
    final hasSepolia = accounts.any((a) => a.startsWith('eip155:11155111:'));
    if (!hasSepolia) {
      await _web3App!.disconnectSession(
        topic: next.topic,
        reason: Errors.getSdkError(Errors.USER_DISCONNECTED),
      );
      _session = null;
      _pairingUri = null;
      _isConnecting = false;
      notifyListeners();
      return;
    }
    _session = next;
    _isConnecting = false;
    _pairingUri = null;
    await ensureSepoliaChain();
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
  Uri? get metamaskDeepLink => _pairingUri == null
      ? null
      : Uri.parse(
          'metamask://wc?uri=${Uri.encodeComponent(_pairingUri.toString())}');
  bool get isConnected => _session != null;
  bool get isConnecting => _isConnecting;
  double? get nativeBalanceEth => _nativeBalanceEth;
  String? get formattedBalance =>
      _nativeBalanceEth == null ? null : _nativeBalanceEth!.toStringAsFixed(4);
}
