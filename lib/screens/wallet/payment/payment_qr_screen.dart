import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../../../config/contracts.dart';
import '../../../models/transaction_item.dart';
import '../../../services/transaction_history_service.dart';
import '../../../services/wallet_connect_singleton.dart';
import 'modals/payment_result_modal.dart';
import 'payment_permission_helper.dart';

class PaymentQrScreen extends StatefulWidget {
  const PaymentQrScreen({super.key});

  @override
  State<PaymentQrScreen> createState() => _PaymentQrScreenState();
}

class _PaymentQrScreenState extends State<PaymentQrScreen> {
  bool _scanned = false;
  bool _isPaying = false;
  bool _cameraReady = false;
  bool _cameraPermanentlyDenied = false;
  String _paymentStatus = 'QR-Code in den Rahmen halten';

  final _wcService = walletConnectService;
  final _historyService = transactionHistoryService;
  final MobileScannerController _scannerController = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  @override
  void initState() {
    super.initState();
    _wcService.init();
    _wcService.resyncActiveSession();
    _historyService.init();
    _requestCameraPermission();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final result = await PaymentPermissionHelper.requestCameraPermission();
    if (mounted) {
      setState(() {
        _cameraReady = result.granted;
        _cameraPermanentlyDenied = result.permanentlyDenied;
      });
    }
  }

  Future<void> _openSettings() async {
    await PaymentPermissionHelper.openSettings();
  }

  Future<bool> _openMetaMask() async {
    final primary = Uri.parse('metamask://');
    final fallback = Uri.parse('https://metamask.app.link/');

    final openedPrimary = await launchUrl(
      primary,
      mode: LaunchMode.externalApplication,
    );
    if (openedPrimary) return true;

    return launchUrl(
      fallback,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<Map<String, dynamic>> _fetchMensaSignature({
    required int amount,
    required BigInt orderId,
    required String payer,
  }) async {
    final uri = Uri.parse('${ContractsConfig.backendUrl}/api/mensa/payment-signature');
    final resp = await http
        .post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amount,
        'orderId': orderId.toInt(),
        'payer': payer,
        'expirySeconds': 300,
      }),
    )
        .timeout(const Duration(seconds: 15));

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Signatur-Anfrage fehlgeschlagen: ${resp.statusCode}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  Future<ContractAbi> _loadAbi(String assetPath, String name) async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final abiJson = jsonEncode(decoded['abi']);
    return ContractAbi.fromJson(abiJson, name);
  }

  Uint8List _hexToBytes32(String hex) {
    final cleaned = hex.startsWith('0x') ? hex.substring(2) : hex;
    final bytes = Uint8List(cleaned.length ~/ 2);
    for (int i = 0; i < bytes.length; i++) {
      final byteStr = cleaned.substring(i * 2, i * 2 + 2);
      bytes[i] = int.parse(byteStr, radix: 16);
    }
    if (bytes.length == 32) return bytes;
    final out = Uint8List(32);
    out.setRange(32 - bytes.length, 32, bytes);
    return out;
  }

  Uint8List _bytes32(String value) {
    final bytes = utf8.encode(value);
    if (bytes.length > 32) {
      throw Exception('Ungültiger Service-Wert (bytes32 zu lang).');
    }
    final out = Uint8List(32);
    out.setRange(0, bytes.length, bytes);
    return out;
  }

  BigInt _toBigInt(dynamic value) {
    if (value is BigInt) return value;
    if (value is int) return BigInt.from(value);
    if (value is num) return BigInt.from(value.toInt());
    if (value is String) return BigInt.parse(value);
    throw Exception('Ungültiger Zahlenwert in der Signaturantwort.');
  }

  Future<String?> _payMensa({required int amount, required BigInt orderId}) async {
    if (!_wcService.isConnected) {
      throw Exception('Wallet ist nicht verbunden.');
    }

    final payer = _wcService.connectedAddress!;
    final sig = await _fetchMensaSignature(
      amount: amount,
      orderId: orderId,
      payer: payer,
    );

    final expiry = _toBigInt(sig['expiry']);
    final v = _toBigInt(sig['v']);
    final r = _hexToBytes32(sig['r'] as String);
    final s = _hexToBytes32(sig['s'] as String);

    final tokenAbi = await _loadAbi('assets/abi/THWSToken.json', 'THWSToken');
    final pmAbi = await _loadAbi('assets/abi/PaymentManager.json', 'PaymentManager');

    final tokenContract = DeployedContract(
      tokenAbi,
      EthereumAddress.fromHex(ContractsConfig.token),
    );
    final pmContract = DeployedContract(
      pmAbi,
      EthereumAddress.fromHex(ContractsConfig.paymentManager),
    );

    final approveFn = tokenContract.function('approve');
    final allowanceFn = tokenContract.function('allowance');
    final approveData = bytesToHex(
      approveFn.encodeCall([
        EthereumAddress.fromHex(ContractsConfig.paymentManager),
        BigInt.from(amount),
      ]),
      include0x: true,
    );

    final payFn = pmContract.function('payServiceWithSig');
    final payData = bytesToHex(
      payFn.encodeCall([
        _bytes32('MENSA'),
        BigInt.from(amount),
        orderId,
        expiry,
        v,
        r,
        s,
      ]),
      include0x: true,
    );

    final allowanceResult = await Web3Client(
      ContractsConfig.rpcUrl,
      http.Client(),
    ).call(
      contract: tokenContract,
      function: allowanceFn,
      params: [
        EthereumAddress.fromHex(payer),
        EthereumAddress.fromHex(ContractsConfig.paymentManager),
      ],
    );
    final allowance = allowanceResult.isNotEmpty && allowanceResult.first is BigInt
        ? allowanceResult.first as BigInt
        : BigInt.zero;

    if (allowance < BigInt.from(amount)) {
      if (mounted) {
        setState(() => _paymentStatus = 'Warte auf Freigabe in MetaMask...');
      }
      final approveFuture = _wcService
          .sendTransaction(
            to: ContractsConfig.token,
            data: approveData,
          )
          .timeout(const Duration(seconds: 90));
      await approveFuture;
    }

    if (mounted) {
      setState(() => _paymentStatus = 'Warte auf Zahlungsbestätigung...');
    }
    final payFuture = _wcService
        .sendTransaction(
          to: ContractsConfig.paymentManager,
          data: payData,
        )
        .timeout(const Duration(seconds: 90));
    return await payFuture;
  }

  ({int amount, BigInt orderId}) _parseQrPayload(String raw) {
    // Default fallback for plain MENSA QR.
    int amount = 500;
    BigInt orderId = BigInt.from(DateTime.now().millisecondsSinceEpoch);

    if (raw.trim().toUpperCase() == 'MENSA') {
      return (amount: amount, orderId: orderId);
    }

    // Legacy employee format support:
    // payment|amount=12.50|nonce=1730000000000
    if (raw.startsWith('payment|')) {
      final parts = raw.split('|');
      double? amountMajor;
      BigInt? nonce;

      for (final part in parts) {
        final kv = part.split('=');
        if (kv.length != 2) continue;
        final key = kv[0].trim();
        final value = kv[1].trim();
        if (key == 'amount') {
          amountMajor = double.tryParse(value.replaceAll(',', '.'));
        } else if (key == 'nonce') {
          nonce = BigInt.tryParse(value);
        }
      }

      if (amountMajor != null && amountMajor > 0) {
        amount = (amountMajor * 100).round();
      }
      if (nonce != null) {
        orderId = nonce;
      }
      return (amount: amount, orderId: orderId);
    }

    final uri = Uri.tryParse(raw);
    if (uri != null && uri.queryParameters.isNotEmpty) {
      final amountStr = uri.queryParameters['amount'];
      final orderStr = uri.queryParameters['orderId'];
      if (amountStr != null) {
        amount = int.tryParse(amountStr) ?? amount;
      }
      if (orderStr != null) {
        orderId = BigInt.tryParse(orderStr) ?? orderId;
      }
      return (amount: amount, orderId: orderId);
    }

    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      final dynamic amountVal = decoded['amount'];
      final dynamic orderVal = decoded['orderId'];
      if (amountVal != null) {
        amount = int.tryParse('$amountVal') ?? amount;
      }
      if (orderVal != null) {
        orderId = BigInt.tryParse('$orderVal') ?? orderId;
      }
      return (amount: amount, orderId: orderId);
    }

    throw Exception('QR-Inhalt wird nicht unterstützt.');
  }

  String _subtitleForTransaction(String? txHash, DateTime at) {
    final dd = at.day.toString().padLeft(2, '0');
    final mm = at.month.toString().padLeft(2, '0');
    final hh = at.hour.toString().padLeft(2, '0');
    final mi = at.minute.toString().padLeft(2, '0');
    final hashPart = (txHash != null && txHash.length >= 10)
        ? ' • ${txHash.substring(0, 10)}...'
        : '';
    return '$dd.$mm $hh:$mi$hashPart';
  }

  Future<void> _processScannedValue(String rawValue) async {
    if (_scanned || _isPaying) return;

    setState(() {
      _scanned = true;
      _isPaying = true;
      _paymentStatus = 'Zahlung wird vorbereitet...';
    });
    await _scannerController.stop();

    bool success = false;
    String? errorMessage;

    try {
      final payload = _parseQrPayload(rawValue.trim());
      await _wcService.ensureSepoliaChain();
      final txHash = await _payMensa(
        amount: payload.amount,
        orderId: payload.orderId,
      );
      final now = DateTime.now();
      await _historyService.addTransaction(
        TransactionItem(
          title: 'Mensa Zahlung',
          subtitle: _subtitleForTransaction(txHash, now),
          amount: payload.amount / 100,
          isExpense: true,
          createdAt: now,
          txHash: txHash,
        ),
      );
      await _wcService.refreshBalance();
      await _wcService.resyncActiveSession();
      success = true;
    } on TimeoutException {
      errorMessage =
          'Zeitüberschreitung bei der Zahlung. Öffne MetaMask manuell und bestätige die Anfrage.';
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isPaying = false;
          _paymentStatus = 'QR-Code in den Rahmen halten';
          if (!success) {
            // Allow rescanning on failure without leaving the page.
            _scanned = false;
          }
        });
        if (!success) {
          await _scannerController.start();
        }
      }
    }

    if (errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentResultModal(
        success: success,
        onClose: () {
          Navigator.pop(context); // modal
          Navigator.pop(context); // qr screen
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'QR scannen',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          if (_cameraReady)
            MobileScanner(
              controller: _scannerController,
              onDetect: (capture) {
                String? rawValue;
                for (final barcode in capture.barcodes) {
                  final value = barcode.rawValue;
                  if (value != null && value.trim().isNotEmpty) {
                    rawValue = value;
                    break;
                  }
                }
                if (rawValue == null || rawValue.isEmpty) return;
                _processScannedValue(rawValue);
              },
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.camera_alt_outlined,
                        color: Colors.white70, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Kamerazugriff ist erforderlich.',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    if (_cameraPermanentlyDenied)
                      ElevatedButton(
                        onPressed: _openSettings,
                        child: const Text('Einstellungen öffnen'),
                      )
                    else
                      ElevatedButton(
                        onPressed: _requestCameraPermission,
                        child: const Text('Berechtigung erneut anfragen'),
                      ),
                  ],
                ),
              ),
            ),

          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.8),
                  width: 2,
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Column(
              children: [
                Text(
                  _paymentStatus,
                  style: const TextStyle(color: Colors.white70),
                ),
                if (_isPaying) ...[
                  const SizedBox(height: 12),
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _openMetaMask,
                    child: const Text('MetaMask öffnen'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
