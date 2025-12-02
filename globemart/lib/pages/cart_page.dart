import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../models/cart_model.dart';
import '../services/hive_service.dart';
import 'address_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartModel> items = [];
  final money = NumberFormat.currency(symbol: "\$", decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  void loadCart() {
    final user = HiveService.getSession();
    if (user == null) return;

    final raw = Hive.box('cart').get(user) ?? [];
    items = raw.map<CartModel>((e) => CartModel.fromMap(e)).toList();
    setState(() {});
  }

  void saveCart() {
    final user = HiveService.getSession();
    if (user == null) return;

    Hive.box('cart').put(user, items.map((e) => e.toMap()).toList());
  }

  void increaseQty(int index) {
    setState(() {
      final item = items[index];
      items[index] = CartModel(
        id: item.id,
        title: item.title,
        price: item.price,
        qty: item.qty + 1,
        image: item.image,
      );
    });
    saveCart();
  }

  void decreaseQty(int index) {
    if (items[index].qty == 1) return;
    setState(() {
      final item = items[index];
      items[index] = CartModel(
        id: item.id,
        title: item.title,
        price: item.price,
        qty: item.qty - 1,
        image: item.image,
      );
    });
    saveCart();
  }

  void removeItem(int index) {
    setState(() => items.removeAt(index));
    saveCart();
  }

  int totalPrice() =>
      items.fold(0, (sum, e) => sum + (e.price * e.qty));

  Widget _emptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: isDark ? Colors.white38 : Colors.black45,
          ),
          const SizedBox(height: 10),
          Text(
            "Keranjang masih kosong",
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildItem(CartModel item, int index) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.image,
                width: 88,
                height: 88,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),

            // INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    money.format(item.price),
                    style: const TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // QTY
                  Row(
                    children: [
                      _qtyButton(Icons.remove, () => decreaseQty(index)),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          item.qty.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      _qtyButton(Icons.add, () => increaseQty(index)),
                    ],
                  ),
                ],
              ),
            ),

            // DELETE
            IconButton(
              onPressed: () => removeItem(index),
              icon: const Icon(Icons.delete, color: Colors.red),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF101216) : Colors.grey[100],
      appBar: AppBar(title: const Text("Keranjang")),

      // ===== STICKY CHECKOUT BAR =====
      bottomNavigationBar: items.isEmpty
          ? null
          : Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // TOTAL
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Total",
                            style:
                                TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            money.format(totalPrice()),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // BUTTON CHECKOUT -> ADDRESS PAGE
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddressPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.credit_card),
                      label: const Text("Checkout"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    )
                  ],
                ),
              ),
            ),

      // ===== BODY =====
      body: items.isEmpty
          ? _emptyState(isDark)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (_, i) => _buildItem(items[i], i),
            ),
    );
  }
}
