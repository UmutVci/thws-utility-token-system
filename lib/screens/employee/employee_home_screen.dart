import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'widgets/employee_header.dart';
import 'widgets/employee_qr_card.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  // RPC URL - MacBook/iOS Simülatör için 127.0.0.1 doğrudur.
  // Eğer Android Simülatöre geçersen burayı 10.0.2.2 yapmalısın.
  final String rpcUrl = "http://127.0.0.1:8545";

  // Terminal çıktındaki güncel PaymentManager adresi:
  final String targetAddress = "0x5FC8d32690cc91D4c39d9d3abcBD16989F875707";

  // Anvil (0) numaralı Private Key (Gönderen hesap):
  final String privateKey =
      "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";

  late Web3Client client;
  String balance = "0.00";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    client = Web3Client(rpcUrl, Client());
    _updateBalance();
  }

  // Bakiyeyi güncelleyen fonksiyon
  Future<void> _updateBalance() async {
    try {
      final credentials = EthPrivateKey.fromHex(privateKey);
      EtherAmount ethBalance = await client.getBalance(credentials.address);
      setState(() {
        balance = ethBalance.getValueInUnit(EtherUnit.ether).toStringAsFixed(4);
      });
    } catch (e) {
      debugPrint("Bakiye okuma hatası: $e");
    }
  }

  // Para gönderme (Ödeme) fonksiyonu
  Future<void> _makePayment() async {
    setState(() => isLoading = true);
    try {
      final credentials = EthPrivateKey.fromHex(privateKey);

      await client.sendTransaction(
        credentials,
        Transaction(
          to: EthereumAddress.fromHex(targetAddress),
          value: EtherAmount.fromInt(EtherUnit.gwei, 10000000), // 0.01 ETH
        ),
        chainId: 31337, // Anvil Local Chain ID
      );

      // İşlemden sonra kısa bir bekleme ve bakiye tazeleme
      await Future.delayed(const Duration(milliseconds: 800));
      await _updateBalance();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ödeme Başarıyla Gönderildi!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("Ödeme hatası: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7BB03C),
      body: SafeArea(
        child: Column(
          children: [
            const EmployeeHeader(),
            const Expanded(child: EmployeeQrCard()),

            // Alt Kısım - Cüzdan ve Ödeme Kartı
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Text("Aktueller Kontostand",
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 5),
                    Text(
                      "$balance THWS",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          elevation: 2,
                        ),
                        onPressed: isLoading ? null : _makePayment,
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text("Zahlen",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
