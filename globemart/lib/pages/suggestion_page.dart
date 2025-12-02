import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/hive_service.dart';

class SuggestionPage extends StatefulWidget {
  const SuggestionPage({super.key});

  @override
  State<SuggestionPage> createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  final titleC = TextEditingController();
  final bodyC = TextEditingController();
  List<Map> list = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() {
    final user = HiveService.getSession();
    final raw = Hive.box('suggestion').get(user) ?? [];
    list = List<Map>.from(raw.map((e) => Map<String, dynamic>.from(e)));
    setState(() {});
  }

  void save() {
    final user = HiveService.getSession();
    Hive.box('suggestion').put(user, list);
  }

  void add() {
    if (bodyC.text.trim().isEmpty) return;

    final data = {
      'title': titleC.text.trim(),
      'body': bodyC.text.trim(),
      'time': DateTime.now().toIso8601String(),
    };

    list.insert(0, data); // TERBARU PALING ATAS
    save();
    titleC.clear();
    bodyC.clear();
    setState(() {});

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Saran berhasil dikirim")),
    );
  }

  void remove(int i) {
    list.removeAt(i);
    save();
    setState(() {});
  }

  void editDialog(int index) {
    final data = list[index];
    final editTitleC = TextEditingController(text: data['title'] ?? '');
    final editBodyC = TextEditingController(text: data['body'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Edit Saran",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 14),
              TextField(
                controller: editTitleC,
                decoration: _field("Judul (Opsional)"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: editBodyC,
                maxLines: 4,
                decoration: _field("Isi saran"),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (editBodyC.text.trim().isEmpty) return;
                    list[index] = {
                      'title': editTitleC.text.trim(),
                      'body': editBodyC.text.trim(),
                      'time': data['time'],
                    };
                    save();
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Text("Simpan"),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  String formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return "${dt.day.toString().padLeft(2, '0')}-"
          "${dt.month.toString().padLeft(2, '0')}-"
          "${dt.year}  "
          "${dt.hour.toString().padLeft(2, '0')}:"
          "${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return iso;
    }
  }

  InputDecoration _field(String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: isDark ? const Color(0xFF2A2A36) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(title: const Text("Saran & Kesan")),
      body: Column(
        children: [

          // ===== INPUT FORM =====
          Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E26) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (!isDark)
                    const BoxShadow(color: Colors.black12, blurRadius: 6),
                ],
              ),
              child: Column(children: [
                TextField(controller: titleC, decoration: _field("Judul (opsional)")),
                const SizedBox(height: 10),
                TextField(
                  controller: bodyC,
                  maxLines: 4,
                  decoration: _field("Tulis saran atau kesan Anda"),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text("Kirim Saran"),
                    onPressed: add,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                )
              ]),
            ),
          ),

          // ===== LIST =====
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text("Belum ada saran"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: list.length,
                    itemBuilder: (c, i) {
                      final item = list[i];
                      final title = (item['title'] ?? '').toString();
                      final body = item['body'];
                      final time = item['time'];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1F1F2B) : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title.isNotEmpty)
                              Text(title,
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                            if (title.isNotEmpty) const SizedBox(height: 6),
                            Text(body),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 14),
                                const SizedBox(width: 4),
                                Text(formatTime(time), style: theme.textTheme.bodySmall),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => editDialog(i),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () => remove(i),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
