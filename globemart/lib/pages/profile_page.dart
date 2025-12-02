import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../services/hive_service.dart';
import '../services/currency_service.dart';
import '../services/location_service.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final picker = ImagePicker();
  String? photoPath;

  int totalTx = 0;
  double totalSpend = 0;
  double growth = 0;
  String lastLocation = "-";
  bool loading = true;

  String rupiah(double value) {
    final f = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return f.format(value);
  }

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // ============================
  // ✅ SAFE TOTAL READER
  // ============================
  double getTotalUsd(Map t) {
    if (t['totalUSD'] != null && t['totalUSD'] is num) {
      return (t['totalUSD'] as num).toDouble();
    }

    if (t['total'] != null && t['total'] is num) {
      return (t['total'] as num).toDouble();
    }

    return 0;
  }

  // ============================
  // ✅ LOAD PROFILE SAFELY
  // ============================
  Future loadProfile() async {
    final user = HiveService.getSession();
    final raw = Hive.box('transaction').get(user) ?? [];

    final List<Map<String, dynamic>> trx =
        List<Map<String, dynamic>>.from(
          raw.map((e) => Map<String, dynamic>.from(e)),
        );

    totalTx = trx.length;

    final rates = await CurrencyService.getRates();
    final usdToIdr = rates['IDR'] ?? 16000;

    double totalUsd = 0;

    for (var t in trx) {
      totalUsd += getTotalUsd(t);
    }

    totalSpend = totalUsd * usdToIdr;

    if (trx.isNotEmpty) {
      growth = getTotalUsd(trx.last) * usdToIdr;
    } else {
      growth = 0;
    }

    try {
      lastLocation = await LocationService.getAddress();
    } catch (_) {
      lastLocation = "-";
    }

    photoPath = Hive.box('profilePhoto').get(user);
    loading = false;

    if (mounted) setState(() {});
  }

  // ============================
  // PHOTO PICKER
  // ============================
  Future pickPhoto(ImageSource src) async {
    final file = await picker.pickImage(source: src, imageQuality: 75);
    if (file != null) {
      Hive.box('profilePhoto').put(HiveService.getSession(), file.path);
      photoPath = file.path;
      setState(() {});
    }
  }

  void showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("Kamera"),
            onTap: () {
              Navigator.pop(context);
              pickPhoto(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text("Galeri"),
            onTap: () {
              Navigator.pop(context);
              pickPhoto(ImageSource.gallery);
            },
          ),
          if (photoPath != null)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Hapus Foto"),
              onTap: () {
                Hive.box('profilePhoto')
                    .delete(HiveService.getSession());
                photoPath = null;
                setState(() {});
                Navigator.pop(context);
              },
            ),
        ]),
      ),
    );
  }

  void logout() {
    HiveService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  // ============================
  // STAT CARD
  // ============================
  Widget stat(
      {required IconData icon,
      required String title,
      required String value,
      Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1B2F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color ?? Colors.indigo),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              )),
          const SizedBox(height: 2),
          Text(title,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 12,
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = HiveService.getSession() ?? "User";
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F0F1A) : Colors.grey[100];
    final card = isDark ? const Color(0xFF1B1B2F) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [

                  // ===== HEADER =====
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(children: [
                      GestureDetector(
                        onTap: showPhotoOptions,
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.grey,
                          backgroundImage:
                              photoPath == null ? null : FileImage(File(photoPath!)),
                          child:
                              photoPath == null ? const Icon(Icons.person) : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(user,
                          style: TextStyle(
                              fontSize: 18,
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600)),
                      Text("@$user",
                          style: TextStyle(
                              color:
                                  isDark ? Colors.white70 : Colors.black45)),
                    ]),
                  ),

                  // ===== DASHBOARD =====
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(children: [

                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          children: [
                            stat(
                                icon: Icons.receipt,
                                title: "Total Transaksi",
                                value: "$totalTx"),
                            stat(
                                icon: Icons.shopping_bag,
                                title: "Total Belanja",
                                value: rupiah(totalSpend)),
                            stat(
                                icon: Icons.trending_up,
                                title: "Kenaikan",
                                value: "+${rupiah(growth)}",
                                color: Colors.green),
                            stat(
                                icon: Icons.location_on,
                                title: "Lokasi Terakhir",
                                value: lastLocation),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Row(children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: loadProfile,
                              icon: const Icon(Icons.refresh),
                              label: const Text("Refresh"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14)),
                              ),
                              onPressed: logout,
                              child: const Text("Logout"),
                            ),
                          ),
                        ])

                      ]),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
