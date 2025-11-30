import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/hive_service.dart';
import '../services/location_service.dart';
import 'checkout_page.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final addressC = TextEditingController();
  List<String> addresses = [];

  @override
  void initState() {
    super.initState();
    loadAddress();
  }

  void loadAddress() {
    final user = HiveService.getSession();
    addresses = List<String>.from(
      Hive.box('address').get(user) ?? [],
    );
    setState(() {});
  }

  // ===== TAMBAH MANUAL =====
  void addAddressManual() {
    final text = addressC.text.trim();
    if (text.isEmpty) return;
    final user = HiveService.getSession();
    addresses.add(text);
    Hive.box('address').put(user, addresses);
    addressC.clear();
    setState(() {});
  }

  // ✅ FIXED: GPS → NAMA TEMPAT
  Future useGPS() async {
    final place = await LocationService.getAddress();
    final user = HiveService.getSession();

    addresses.add(place);
    Hive.box('address').put(user, addresses);
    setState(() {});
  }

  void removeAddress(int i) {
    final user = HiveService.getSession();
    addresses.removeAt(i);
    Hive.box('address').put(user, addresses);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alamat Pengiriman")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [

              // ===== INPUT =====
              TextField(
                controller: addressC,
                decoration: const InputDecoration(
                  labelText: "Alamat Manual",
                  hintText: "Tulis alamat lengkap",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 8),

              Row(children: [

                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text("Simpan"),
                    onPressed: addAddressManual,
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton.icon(
                  icon: const Icon(Icons.location_on),
                  label: const Text("GPS"),
                  onPressed: useGPS,
                ),
              ]),
            ]),
          ),

          const Divider(),

          // ===== LIST ALAMAT =====
          Expanded(
            child: addresses.isEmpty
                ? const Center(child: Text("Belum ada alamat"))
                : ListView.builder(
                    itemCount: addresses.length,
                    itemBuilder: (c, i) {
                      return ListTile(
                        leading: const Icon(Icons.home),
                        title: Text(addresses[i]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => removeAddress(i),
                            ),

                            ElevatedButton(
                              child: const Text("Pilih"),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CheckoutPage(
                                      selectedAddress: addresses[i],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
