import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  void loadCart() {
    final user = HiveService.getSession();
    List raw = Hive.box('cart').get(user) ?? [];
    items = raw.map((e) => CartModel.fromMap(e)).toList();
    setState(() {});
  }

  void saveCart() {
    final user = HiveService.getSession();
    Hive.box('cart').put(user, items.map((e) => e.toMap()).toList());
  }

  void increaseQty(int i) {
    setState(() {
      items[i] = CartModel(
        id: items[i].id,
        title: items[i].title,
        price: items[i].price,
        qty: items[i].qty + 1,
        image: items[i].image,
      );
    });
    saveCart();
  }

  void decreaseQty(int i) {
    if (items[i].qty > 1) {
      setState(() {
        items[i] = CartModel(
          id: items[i].id,
          title: items[i].title,
          price: items[i].price,
          qty: items[i].qty - 1,
          image: items[i].image,
        );
      });
      saveCart();
    }
  }

  void removeItem(int i) {
    setState(() => items.removeAt(i));
    saveCart();
  }

  int totalPrice() {
    return items.fold(0, (sum, item) => sum + (item.price * item.qty));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Keranjang")),

      // ✅ STICKY CHECKOUT BAR
      bottomNavigationBar: items.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Total: \$${totalPrice()}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddressPage(),
                        ),
                      );
                    },
                    child: const Text("Checkout"),
                  )
                ],
              ),
            ),

      // ✅ BODY
      body: items.isEmpty
          ? const Center(child: Text("Keranjang masih kosong"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.image,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "\$${item.price}",
                              style:
                                  const TextStyle(color: Colors.indigo),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () => decreaseQty(i),
                                ),
                                Text(
                                  item.qty.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => increaseQty(i),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeItem(i),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
