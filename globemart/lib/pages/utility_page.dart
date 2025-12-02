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

  Widget section(BuildContext context, String title, Widget child) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E26) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            const BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }

  InputDecoration fieldDecoration(String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: isDark ? const Color(0xFF2A2A36) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor:
          theme.brightness == Brightness.dark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(title: const Text("Utility Tools")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [

                // ==== CURRENCY ====
                section(
                  context,
                  "Konversi Mata Uang",
                  Column(
                    children: [
                      TextField(
                        keyboardType: TextInputType.number,
                        style: theme.textTheme.bodyMedium,
                        decoration:
                            fieldDecoration("Nilai USD", Icons.attach_money),
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
                        onChanged: (v) =>
                            setState(() => selectedCurrency = v!),
                        decoration:
                            fieldDecoration("Tujuan", Icons.public),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          convertedCurrency().toStringAsFixed(2),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.indigoAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                // ==== TIME CONVERTER ====
                section(
                  context,
                  "Konversi Waktu",
                  Column(
                    children: [
                      TextField(
                        controller: timeC,
                        keyboardType: TextInputType.datetime,
                        style: theme.textTheme.bodyMedium,
                        decoration:
                            fieldDecoration("Format HH:mm", Icons.access_time),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: baseZone,
                        decoration:
                            fieldDecoration("Zona Asal", Icons.pin_drop),
                        items: zoneOffset.keys
                            .map((z) =>
                                DropdownMenuItem(value: z, child: Text(z)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => baseZone = v!),
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
                          ? Text(
                              "Hasil akan tampil di bawah",
                              style: theme.textTheme.bodySmall,
                            )
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
                    ],
                  ),
                ),

                // ==== WORLD TIME ====
                section(
                  context,
                  "Waktu Dunia (Real API)",
                  Wrap(
                    spacing: 8,
                    children: worldTime.entries.map((e) {
                      return Chip(
                        label: Text("${e.key}: ${e.value}"),
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF2A2A36)
                                : Colors.grey[200],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
