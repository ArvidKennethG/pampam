import 'package:flutter/material.dart';

class TimeConverterPage extends StatefulWidget {
  const TimeConverterPage({super.key});

  @override
  State<TimeConverterPage> createState() => _TimeConverterPageState();
}

class _TimeConverterPageState extends State<TimeConverterPage> {
  final TextEditingController timeController = TextEditingController();

  String selectedZone = "WIB";

  Map<String, int> zoneOffset = {
    "WIB": 7,
    "WITA": 8,
    "WIT": 9,
    "London": 0,
  };

  Map<String, String> result = {};

  void convertTime() {
    if (timeController.text.isEmpty) return;

    try {
      final parts = timeController.text.split(":");
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      int baseOffset = zoneOffset[selectedZone]!;

      Map<String, String> temp = {};

      zoneOffset.forEach((zone, offset) {
        int convert = hour + (offset - baseOffset);
        if (convert < 0) convert += 24;
        if (convert >= 24) convert -= 24;

        temp[zone] =
            "${convert.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
      });

      setState(() {
        result = temp;
      });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Format waktu salah. Gunakan HH:mm")),
      );
    }
  }

  @override
  void dispose() {
    timeController.dispose();
    super.dispose();
  }

  Widget buildResult(String zone, String time) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.access_time),
        title: Text(zone),
        trailing: Text(
          time,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Konversi Waktu Dunia")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // INPUT TIME
            TextField(
              controller: timeController,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                hintText: "Masukkan waktu (HH:mm)",
                prefixIcon: Icon(Icons.schedule),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // DROPDOWN ZONE
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Zona Asal",
                border: OutlineInputBorder(),
              ),
              value: selectedZone,
              items: zoneOffset.keys.map((zone) {
                return DropdownMenuItem(
                  value: zone,
                  child: Text(zone),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => selectedZone = val!);
              },
            ),

            const SizedBox(height: 12),

            // BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.compare_arrows),
                label: const Text("Konversi"),
                onPressed: convertTime,
              ),
            ),

            const Divider(),

            // RESULT
            Expanded(
              child: result.isEmpty
                  ? const Center(
                      child: Text("Hasil konversi muncul di sini"),
                    )
                  : ListView(
                      children: result.entries
                          .map((e) => buildResult(e.key, e.value))
                          .toList(),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
