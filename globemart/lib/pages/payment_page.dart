import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../services/hive_service.dart';
import '../services/local_notification_service.dart';
import 'invoice_page.dart';

class PaymentPage extends StatefulWidget {
  final String address;
  final double total;

  const PaymentPage({super.key, required this.address, required this.total});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedMethod = "Bank Transfer";
  final methods = ["Bank Transfer", "QRIS", "E-Wallet"];
  final uuid = const Uuid();

  Future processPayment() async {
    final user = HiveService.getSession();
    if (user == null) return;

    final cartBox = Hive.box('cart');
    final trxBox = Hive.box('transaction');

    final List cartItems = cartBox.get(user) ?? [];
    List history = trxBox.get(user) ?? [];

    final trx = {
      "trxId": uuid.v4(), // ✅ ID UNIK
      "date": DateTime.now().toIso8601String(),
      "address": widget.address,
      "method": selectedMethod,
      "total": widget.total,
      "items": cartItems,
    };

    history.add(trx);
    trxBox.put(user, history);

    // Clear cart
    cartBox.put(user, []);

    await LocalNotificationService.notifySuccess();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => InvoicePage(transaction: trx)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Pembayaran")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [

          // ADDRESS
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Alamat Pengiriman",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(widget.address),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // PAYMENT METHOD
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: Column(
              children: methods.map((m) {
                return RadioListTile(
                  title: Text(m),
                  value: m,
                  groupValue: selectedMethod,
                  onChanged: (v) => setState(() => selectedMethod = v!),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),

          // TOTAL
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text("Total Pembayaran",
                      style: TextStyle(color: Colors.white70)),
                ),
                Text(
                  "\$${widget.total.toStringAsFixed(2)}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.payment),
              label: const Text("BAYAR SEKARANG"),
              onPressed: processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.all(14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
