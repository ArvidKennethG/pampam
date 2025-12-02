import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../services/api_service.dart';
import '../services/hive_service.dart';
import '../services/local_notification_service.dart';
import '../services/theme_service.dart';

import '../models/product_model.dart';
import '../utils/page_transition.dart';

import 'product_detail_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'suggestion_page.dart';
import 'utility_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  final pages = const [_ShopHome(), SuggestionPage(), ProfilePage()];

  @override
  void initState() {
    super.initState();
    checkCartNotification();
  }

  void checkCartNotification() {
    final user = HiveService.getSession();
    if (user == null) return;
    final List cart = Hive.box('cart').get(user) ?? [];
    if (cart.isNotEmpty) {
      LocalNotificationService.notifyPendingCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: "Saran"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}

// ==============================
// SHOP HOME PAGE
// ==============================
class _ShopHome extends StatefulWidget {
  const _ShopHome();
  @override
  State<_ShopHome> createState() => _ShopHomeState();
}

class _ShopHomeState extends State<_ShopHome> with SingleTickerProviderStateMixin {
  List<ProductModel> products = [];
  List<Map<String, dynamic>> categories = [];
  bool loading = true;
  String selectedCategory = "all";
  final searchC = TextEditingController();

  late AnimationController fadeCtr;

  @override
  void initState() {
    super.initState();
    fadeCtr = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    loadAll();
  }

  @override
  void dispose() {
    fadeCtr.dispose();
    super.dispose();
  }

  Future loadAll() async {
    final p = await ApiService.getProducts();
    final c = await ApiService.getCategories();
    setState(() {
      products = p;
      categories = c;
      loading = false;
    });
    fadeCtr.forward();
  }

  Future filterCategory(String slug) async {
    setState(() => loading = true);
    products = slug == "all"
        ? await ApiService.getProducts()
        : await ApiService.getProductByCategory(slug);
    selectedCategory = slug;
    setState(() => loading = false);
  }

  Future searchProduct() async {
    setState(() => loading = true);
    products = await ApiService.searchProduct(searchC.text);
    setState(() => loading = false);
  }

  void openUtility() =>
      Navigator.push(context, PageTransition.slideFade(const UtilityPage()));

  void openCart() =>
      Navigator.push(context, PageTransition.slideFade(const CartPage()));

  void openDetail(ProductModel p) =>
      Navigator.push(context, PageTransition.slideFade(ProductDetailPage(product: p)));

  Widget categoryChip(String name, String slug) {
    final active = selectedCategory == slug;
    return InkWell(
      onTap: () => filterCategory(slug),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.indigo : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? Colors.transparent : Colors.grey.shade400,
          ),
        ),
        child: Text(
          name.toUpperCase(),
          style: TextStyle(
            color: active ? Colors.white : Theme.of(context).textTheme.bodyMedium!.color,
            fontWeight: FontWeight.w600,
            letterSpacing: .3,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF101216) : Colors.grey[100];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("GLOBE MART"),
        centerTitle: true,
        elevation: 0,
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeService.themeNotifier,
            builder: (_, mode, __) {
              return IconButton(
                icon: Icon(
                  mode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
                ),
                onPressed: ThemeService.toggleTheme,
              );
            },
          ),
          IconButton(icon: const Icon(Icons.widgets), onPressed: openUtility),
          IconButton(icon: const Icon(Icons.shopping_cart), onPressed: openCart),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(62),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchC,
                    decoration: InputDecoration(
                      hintText: "Cari produk...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text("Cari"),
                  onPressed: searchProduct,
                )
              ],
            ),
          ),
        ),
      ),

      body: FadeTransition(
        opacity: fadeCtr,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // ===== CATEGORY BAR =====
                  SizedBox(
                    height: 52,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      children: [
                        categoryChip("All", "all"),
                        ...categories.map((e) => categoryChip(e['name'], e['slug'])),
                      ],
                    ),
                  ),

                  // ===== PRODUCT GRID =====
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: products.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.74,
                      ),
                      itemBuilder: (_, i) {
                        return ProductCard(
                          product: products[i],
                          onTap: openDetail,
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ==============================
// PRODUCT CARD UI (ANTI OVERFLOW)
// ==============================
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final Function(ProductModel) onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => onTap(product),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ===== IMAGE (FIXED HEIGHT) =====
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.network(
                  product.thumbnail,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),

            // ===== CONTENT =====
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // TITLE (ANTI OVERFLOW)
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),

                    const Spacer(),

                    // PRICE + STATUS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "\$${product.price}",
                          style: const TextStyle(
                            color: Colors.indigo,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "READY",
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
