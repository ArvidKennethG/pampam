import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../services/hive_service.dart';
import '../services/local_notification_service.dart';
import 'invoice_page.dart';

class PaymentPage extends StatefulWidget {
  final String address;
  final double totalUSD;
  final double displayTotal;
  final String currency;

  const PaymentPage({
    super.key,
    required this.address,
    required this.totalUSD,
    required this.displayTotal,
    required this.currency,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedMethod = "Bank Transfer";
  final methods = ["Bank Transfer", "QRIS", "E-Wallet"];
  final uuid = const Uuid();

  String formatTotal() {
    switch (widget.currency) {
      case "IDR":
        return "Rp ${widget.displayTotal.toStringAsFixed(0)}";
      case "JPY":
        return "¥ ${widget.displayTotal.toStringAsFixed(0)}";
      case "EUR":
        return "€ ${widget.displayTotal.toStringAsFixed(2)}";
      case "GBP":
        return "£ ${widget.displayTotal.toStringAsFixed(2)}";
      default:
        return "\$ ${widget.totalUSD.toStringAsFixed(2)}";
    }
  }

  Future processPayment() async {
    final user = HiveService.getSession();
    if (user == null) return;

    final cartBox = Hive.box('cart');
    final trxBox = Hive.box('transaction');

    final List cartItems = cartBox.get(user) ?? [];
    List history = trxBox.get(user) ?? [];

    final trx = {
      "trxId": uuid.v4(),
      "date": DateTime.now().toIso8601String(),
      "address": widget.address,
      "method": selectedMethod,

      // ✅ SIMPAN BENAR
      "totalUSD": widget.totalUSD,
      "displayTotal": widget.displayTotal,
      "currency": widget.currency,

      "items": cartItems,
    };

    history.add(trx);
    trxBox.put(user, history);

    cartBox.put(user, []);

    await LocalNotificationService.notifySuccess();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => InvoicePage(transaction: trx)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1C28) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitle = isDark ? Colors.white70 : Colors.black54;
    final surface = isDark ? const Color(0xFF121212) : Colors.grey[100];

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(title: const Text("Pembayaran")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [

          // ==== ADDRESS ====
          _card(
            cardColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Alamat Pengiriman",
                    style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 6),
                Text(widget.address, style: TextStyle(color: subtitle)),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ==== PAYMENT METHOD ====
          _card(
            cardColor,
            child: Column(
              children: methods.map((m) {
                return RadioListTile(
                  activeColor: Colors.indigo,
                  title: Text(m, style: TextStyle(color: textColor)),
                  value: m,
                  groupValue: selectedMethod,
                  onChanged: (v) => setState(() => selectedMethod = v!),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),

          // ==== TOTAL PAYMENT ====
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Total Pembayaran",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                Text(
                  formatTotal(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // ==== PAY BUTTON ====
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.payment),
              label: const Text("BAYAR SEKARANG"),
              onPressed: processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 6,
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _card(Color color, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8),
        ],
      ),
      child: child,
    );
  }
}
