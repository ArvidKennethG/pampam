import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';
import '../services/hive_service.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int qty = 1;

  void addToCart() {
    final user = HiveService.getSession();
    final box = Hive.box('cart');
    List list = box.get(user) ?? [];

    bool exist = false;
    for (var item in list) {
      if (item['id'] == widget.product.id) {
        item['qty'] += qty;
        exist = true;
      }
    }

    if (!exist) {
      list.add(
        CartModel(
          id: widget.product.id,
          title: widget.product.title,
          price: widget.product.price,
          qty: qty,
          image: widget.product.thumbnail,
        ).toMap(),
      );
    }

    box.put(user, list);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Produk ditambahkan ke keranjang"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(p.title),
        centerTitle: true,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "\$${p.price}",
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo),
              ),
            ),
            ElevatedButton.icon(
              onPressed: addToCart,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text("Tambah"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            )
          ],
        ),
      ),
      body: ListView(
        children: [

          // ===== HERO IMAGE =====
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
            child: Image.network(
              p.thumbnail,
              height: 280,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 14),

          // ===== PRODUCT INFO =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  p.description,
                  style: const TextStyle(color: Colors.black87),
                ),

                const SizedBox(height: 16),

                // ===== QTY =====
                Row(
                  children: [
                    const Text("Jumlah:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (qty > 1) qty--;
                              });
                            },
                            icon: const Icon(Icons.remove),
                          ),
                          Text(
                            "$qty",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                qty++;
                              });
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    )
                  ],
                ),

              ],
            ),
          )
        ],
      ),
    );
  }
}
