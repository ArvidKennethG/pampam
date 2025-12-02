import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/product_model.dart';
import '../models/cart_model.dart';
import '../services/hive_service.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int qty = 1;

  // ==========================
  //  ADD TO CART LOGIC
  // ==========================
  void _addToCart() {
    final user = HiveService.getSession();
    if (user == null) return;

    final box = Hive.box('cart');
    final List raw = box.get(user) ?? [];

    // pastikan list bisa dimodifikasi
    final List<Map<String, dynamic>> list = raw
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    bool found = false;
    for (final item in list) {
      if (item['id'] == widget.product.id) {
        item['qty'] = (item['qty'] as int) + qty;
        found = true;
        break;
      }
    }

    if (!found) {
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

  // ==========================
  //  UI
  // ==========================
  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final int totalPrice = p.price * qty;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101216) : Colors.grey[100],
      appBar: AppBar(
        title: Text(
          p.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),

      // ---------- BOTTOM BAR ----------
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Total harga
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      "\$$totalPrice",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
              ),

              // Tombol tambah ke keranjang
              ElevatedButton.icon(
                onPressed: _addToCart,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text("Tambah"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              )
            ],
          ),
        ),
      ),

      // ---------- BODY ----------
      body: ListView(
        children: [
          // HERO IMAGE
          Container(
            color: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: AspectRatio(
                aspectRatio: 1.1,
                child: Hero(
                  tag: "product-${p.id}",
                  child: Image.network(
                    p.thumbnail,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Icon(Icons.broken_image, size: 48)),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // CONTENT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITLE + PRICE
                Text(
                  p.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "\$${p.price}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),

                const SizedBox(height: 16),

                // QTY SELECTOR
                Row(
                  children: [
                    const Text(
                      "Jumlah",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
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
                            qty.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
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
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // DESCRIPTION
                Text(
                  "Deskripsi",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    p.description,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
