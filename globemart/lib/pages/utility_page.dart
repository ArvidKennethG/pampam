import 'package:flutter/material.dart';
import '../services/currency_service.dart';
import '../services/world_time_service.dart';

class UtilityPage extends StatefulWidget {
  const UtilityPage({super.key});

  @override
  State<UtilityPage> createState() => _UtilityPageState();
}

class _UtilityPageState extends State<UtilityPage> {
  // ===== CURRENCY =====
  double usdValue = 1;
  String selectedCurrency = "IDR";
  Map<String, double> rates = {};

  // ===== TIME =====
  final TextEditingController timeC = TextEditingController();
  String baseZone = "WIB";
  Map<String, int> zoneOffset = {
    "WIB": 7,
    "WITA": 8,
    "WIT": 9,
    "London": 0,
  };
  Map<String, String> converted = {};

  // ===== WORLD TIME =====
  Map<String, String> worldTime = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async {
    rates = await CurrencyService.getRates();
    worldTime = await WorldTimeService.getAll();
    setState(() => loading = false);
  }

  double convertedCurrency() {
    return usdValue * (rates[selectedCurrency] ?? 1);
  }

  void convertTime() {
    if (timeC.text.isEmpty) return;
    try {
      final parts = timeC.text.split(":");
      int h = int.parse(parts[0]);
      int m = int.parse(parts[1]);
      int baseOffset = zoneOffset[baseZone]!;

      Map<String, String> temp = {};
      zoneOffset.forEach((zone, offset) {
        int nh = h + (offset - baseOffset);
        if (nh < 0) nh += 24;
        if (nh >= 24) nh -= 24;

        temp[zone] =
            "${nh.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
      });

      setState(() => converted = temp);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Format waktu harus HH:mm")),
      );
    }
  }

  Widget section(String title, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Utility Tools")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [

                // ==== CURRENCY ====
                section(
                  "Konversi Mata Uang",
                  Column(
                    children: [
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Nilai USD",
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) {
                          usdValue = double.tryParse(v) ?? 0;
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedCurrency,
                        items: rates.keys
                            .map((k) =>
                                DropdownMenuItem(value: k, child: Text(k)))
                            .toList(),
                        onChanged: (v) => setState(() => selectedCurrency = v!),
                        decoration: const InputDecoration(
                          labelText: "Tujuan",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          convertedCurrency().toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                // ==== TIME CONVERTER ====
                section(
                  "Konversi Waktu",
                  Column(children: [
                    TextField(
                      controller: timeC,
                      keyboardType: TextInputType.datetime,
                      decoration: const InputDecoration(
                        hintText: "HH:mm",
                        prefixIcon: Icon(Icons.access_time),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: baseZone,
                      decoration: const InputDecoration(
                        labelText: "Zona Asal",
                        border: OutlineInputBorder(),
                      ),
                      items: zoneOffset.keys
                          .map((z) => DropdownMenuItem(value: z, child: Text(z)))
                          .toList(),
                      onChanged: (v) => setState(() => baseZone = v!),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.compare_arrows),
                        label: const Text("Konversi"),
                        onPressed: convertTime,
                      ),
                    ),
                    const SizedBox(height: 10),
                    converted.isEmpty
                        ? const Text("Hasil akan tampil di bawah")
                        : Column(
                            children: converted.entries.map((e) {
                              return ListTile(
                                leading:
                                    const Icon(Icons.access_time_filled),
                                title: Text(e.key),
                                trailing: Text(
                                  e.value,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                          )
                  ]),
                ),

                // ==== WORLD TIME ====
                section(
                  "Waktu Dunia (Real API)",
                  Wrap(
                    spacing: 8,
                    children: worldTime.entries.map((e) {
                      return Chip(label: Text("${e.key}: ${e.value}"));
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
