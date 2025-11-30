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
    list.add(data);
    save();
    titleC.clear();
    bodyC.clear();
    setState(() {});
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Edit Saran / Kesan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: editTitleC,
                decoration: const InputDecoration(
                  labelText: "Judul (opsional)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: editBodyC,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Isi saran / kesan",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Simpan Perubahan"),
                  onPressed: () {
                    if (editBodyC.text.trim().isEmpty) return;
                    list[index] = {
                      'title': editTitleC.text.trim(),
                      'body': editBodyC.text.trim(),
                      'time': data['time'], // waktu awal tetap
                    };
                    save();
                    setState(() {});
                    Navigator.pop(context);
                  },
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
          "${dt.year} "
          "${dt.hour.toString().padLeft(2, '0')}:"
          "${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Saran & Kesan")),
      body: Column(
        children: [
          // ===== INPUT FORM =====
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: titleC,
                    decoration: const InputDecoration(
                      labelText: "Judul (opsional)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: bodyC,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Isi saran / kesan",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text("Kirim"),
                      onPressed: add,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 0),

          // ===== LIST SUGGESTION =====
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text("Belum ada saran"))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: list.length,
                    itemBuilder: (c, i) {
                      final item = list[i];
                      final title = (item['title'] ?? '').toString().trim();
                      final body = (item['body'] ?? '').toString();
                      final time = (item['time'] ?? '').toString();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title.isNotEmpty)
                              Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            if (title.isNotEmpty) const SizedBox(height: 4),
                            Text(body),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  formatTime(time),
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600]),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  onPressed: () => editDialog(i),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      size: 18, color: Colors.red),
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
