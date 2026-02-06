import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3dart/web3dart.dart';

import '../../../config/contracts.dart';
import '../../../services/wallet_connect_singleton.dart';
import 'modals/payment_result_modal.dart';


class PaymentQrScreen extends StatefulWidget {
  const PaymentQrScreen({super.key});

  @override
  State<PaymentQrScreen> createState() => _PaymentQrScreenState();
}

class _PaymentQrScreenState extends State<PaymentQrScreen> {
  bool _scanned = false;
  bool _isPaying = false;
  String? _error;

  final _wcService = walletConnectService;

  @override
  void initState() {
    super.initState();
    _wcService.init();
    _wcService.resyncActiveSession();
  }

  @override
  void dispose() {
    super.dispose();
  }



  Future<void> _openMetaMask() async {
    final uri = Uri.parse('metamask://');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // ignore
    }
  }

  Future<Map<String, dynamic>> _fetchMensaSignature({
    required int amount,
    required BigInt orderId,
    required String payer,
  }) async {
    final uri = Uri.parse('${ContractsConfig.backendUrl}/api/mensa/payment-signature');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amount,
        'orderId': orderId.toInt(),
        'payer': payer,
        'expirySeconds': 300
      }),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Signature failed: ${resp.statusCode}');
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
      throw Exception('bytes32 overflow: $value');
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
    throw Exception('Unsupported numeric type: ${value.runtimeType}');
  }

  Future<bool> _payMensa() async {
    if (!_wcService.isConnected) {
      throw Exception('Wallet not connected');
    }

    const int amount = 500; // 5.00 THWS (2 decimals)
    final orderId = BigInt.from(DateTime.now().millisecondsSinceEpoch);
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

    await _openMetaMask();
    await _wcService.sendTransaction(
      to: ContractsConfig.token,
      data: approveData,
    );

    await _openMetaMask();
    await _wcService.sendTransaction(
      to: ContractsConfig.paymentManager,
      data: payData,
    );

    return true;
  }

  void _simulateScan({required bool success}) async {
    if (_scanned) return;
    setState(() => _scanned = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    bool finalSuccess = success;
    String? errorMessage;

    if (success) {
      setState(() {
        _isPaying = true;
        _error = null;
      });

      try {
        await _wcService.ensureSepoliaChain();
        await _payMensa();
      } catch (e) {
        finalSuccess = false;
        errorMessage = e.toString();
      } finally {
        if (mounted) {
          setState(() => _isPaying = false);
        }
      }
    }

    if (errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentResultModal(
        success: finalSuccess,
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
          // Kamera placeholder
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

          // Alt bilgi
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Column(
              children: const [
                Text(
                  'Halte den QR-Code in den Rahmen',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          // DEBUG BUTONLAR (sonra silinecek)
          Positioned(
            left: 20,
            right: 20,
            bottom: 100,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: _isPaying ? null : () => _simulateScan(success: true),
                    child: _isPaying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Pay Mensa'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => _simulateScan(success: false),
                    child: const Text('Simulate Error'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

