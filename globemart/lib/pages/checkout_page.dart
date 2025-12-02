import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/cart_model.dart';
import '../services/hive_service.dart';
import '../services/currency_service.dart';
import 'payment_page.dart';

class CheckoutPage extends StatefulWidget {
  final String selectedAddress;
  const CheckoutPage({super.key, required this.selectedAddress});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  List<CartModel> items = [];
  Map<String, double> rates = {};
  bool loading = true;

  String selectedCurrency = "USD";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final user = HiveService.getSession();
    List raw = Hive.box('cart').get(user) ?? [];
    items = raw.map((e) => CartModel.fromMap(e)).toList();

    rates = await CurrencyService.getRates();
    setState(() => loading = false);
  }

  double totalUSD() {
    return items.fold<double>(
      0,
      (s, i) => s + (i.price * i.qty),
    );
  }

  double convertedTotal() {
    return totalUSD() * (rates[selectedCurrency] ?? 1);
  }

  String format(double value) {
    switch (selectedCurrency) {
      case "IDR":
        return "Rp ${value.toStringAsFixed(0)}";
      case "JPY":
        return "¥ ${value.toStringAsFixed(0)}";
      case "EUR":
        return "€ ${value.toStringAsFixed(2)}";
      case "GBP":
        return "£ ${value.toStringAsFixed(2)}";
      default:
        return "\$ ${value.toStringAsFixed(2)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          const Text("Alamat Pengiriman",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(widget.selectedAddress),

          const SizedBox(height: 16),

          const Text("Mata Uang",
              style: TextStyle(fontWeight: FontWeight.bold)),

          DropdownButtonFormField<String>(
            value: selectedCurrency,
            items: rates.keys
                .map((cur) => DropdownMenuItem(value: cur, child: Text(cur)))
                .toList(),
            onChanged: (val) => setState(() => selectedCurrency = val!),
          ),

          const SizedBox(height: 16),
          const Divider(),

          const Text("Total Pembayaran",
              style: TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 6),
          Text(
            format(convertedTotal()),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              child: const Text("Lanjut ke Pembayaran"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentPage(
                      address: widget.selectedAddress,
                      totalUSD: totalUSD(),              
                      displayTotal: convertedTotal(),   
                      currency: selectedCurrency,       
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
