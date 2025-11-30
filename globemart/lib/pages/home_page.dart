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

// =====================
//  SHOP HOME PAGE
// =====================
class _ShopHome extends StatefulWidget {
  const _ShopHome();
  @override
  State<_ShopHome> createState() => _ShopHomeState();
}

class _ShopHomeState extends State<_ShopHome> with TickerProviderStateMixin {
  List<ProductModel> products = [];
  List<Map<String, dynamic>> categories = [];
  bool loading = true;
  String selectedCategory = "all";
  final searchC = TextEditingController();

  AnimationController? fadeCtr;

  @override
  void initState() {
    super.initState();
    fadeCtr = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    loadAll();
  }

  @override
  void dispose() {
    fadeCtr?.dispose();
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
    fadeCtr?.forward();
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
          color: active ? Colors.indigo : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
          boxShadow: active
              ? const [BoxShadow(color: Colors.black12, blurRadius: 6)]
              : null,
        ),
        child: Text(
          name.toUpperCase(),
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            letterSpacing: .5,
          ),
        ),
      ),
    );
  }

  void openUtility() =>
      Navigator.push(context, PageTransition.slideFade(const UtilityPage()));

  void openCart() =>
      Navigator.push(context, PageTransition.slideFade(const CartPage()));

  void openDetail(ProductModel p) {
    Navigator.push(
      context,
      PageTransition.slideFade(ProductDetailPage(product: p)),
    );
  }

  Widget _buildBodyContent() {
    return Column(
      children: [
        // ===== CATEGORY STRIP =====
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              categoryChip("All", "all"),
              ...categories
                  .map((e) => categoryChip(e['name'], e['slug']))
                  .toList(),
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
              childAspectRatio: .70,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (_, i) =>
                ProductCard(product: products[i], onTap: openDetail),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = loading
        ? const Center(child: CircularProgressIndicator())
        : _buildBodyContent();

    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                    decoration: const InputDecoration(
                      hintText: "Cari produk...",
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
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

      body: (fadeCtr == null)
          ? body
          : FadeTransition(
              opacity: fadeCtr!,
              child: body,
            ),
    );
  }
}

// =====================
// PRODUCT CARD COMPONENT
// =====================
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final Function(ProductModel) onTap;
  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => onTap(product),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: Stack(
                children: [
                  Image.network(
                    product.thumbnail,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // INFO
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${product.price}",
                        style: const TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "READY",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
