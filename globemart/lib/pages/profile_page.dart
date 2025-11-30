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

  Future loadProfile() async {
    final user = HiveService.getSession();
    final raw = Hive.box('transaction').get(user) ?? [];

    List<Map<String, dynamic>> trx = [];
    for (var item in raw) {
      trx.add(Map<String, dynamic>.from(item));
    }

    totalTx = trx.length;

    // ✅ AMBIL KURS
    final rates = await CurrencyService.getRates();
    final usdToIdr = rates['IDR'] ?? 16000;

    // ✅ HITUNG TOTAL
    double totalUsd = trx.fold(0.0,
        (sum, t) => sum + (t['total'] as num).toDouble());

    totalSpend = totalUsd * usdToIdr;

    // ✅ HITUNG KENAIKAN
    if (trx.isNotEmpty) {
      double lastUsd = (trx.last['total'] as num).toDouble();
      growth = lastUsd * usdToIdr;
    }

    // ✅ AMBIL LOKASI (NAMA TEMPAT)
    lastLocation = await LocationService.getAddress();

    photoPath = Hive.box('profilePhoto').get(user);
    setState(() {});
  }

  // ================= PHOTO =================
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

  // ================= CARD =================
  Widget stat(IconData icon, String title, String value,
      {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color ?? Colors.white),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 2),
          Text(title,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = HiveService.getSession() ?? "User";

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          children: [

            // ===== HEADER =====
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(children: [
                GestureDetector(
                  onTap: showPhotoOptions,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        photoPath == null
                            ? null
                            : FileImage(File(photoPath!)),
                    child:
                        photoPath == null ? const Icon(Icons.person) : null,
                  ),
                ),
                const SizedBox(height: 10),
                Text(user,
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
                Text("@$user",
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
              ]),
            ),

            // ===== DASHBOARD =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B2F),
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
                      stat(Icons.receipt, "Total Transaksi", "$totalTx"),
                      stat(Icons.shopping_bag, "Total Belanja",
                          rupiah(totalSpend)),
                      stat(Icons.trending_up, "Kenaikan",
                          "+${rupiah(growth)}",
                          color: Colors.greenAccent),
                      stat(Icons.location_on, "Lokasi Terakhir",
                          lastLocation),
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
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
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
