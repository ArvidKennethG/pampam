import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final userC = TextEditingController();
  final passC = TextEditingController();
  bool hide = true;

  void doRegister() {
    if (userC.text.isEmpty || passC.text.isEmpty) {
      _snack("Semua field wajib diisi");
      return;
    }

    final created = HiveService.register(userC.text, passC.text);
    if (created) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      _snack("Username sudah digunakan");
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF121212) : Colors.white;
    final card = isDark ? const Color(0xFF1E1E2A) : Colors.white;
    final text = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Icon(Icons.person_add,
                    size: 60, color: Colors.indigo),
                const SizedBox(height: 10),
                Text("Daftar Akun",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: text)),
                const SizedBox(height: 4),
                Text("Buat akun GlobeMart",
                    style: TextStyle(color: text.withOpacity(.6))),
                const SizedBox(height: 24),

                // USERNAME
                TextField(
                  controller: userC,
                  style: TextStyle(color: text),
                  decoration: InputDecoration(
                    labelText: "Username",
                    prefixIcon: const Icon(Icons.person),
                    filled: true,
                    fillColor: isDark ? Colors.black26 : Colors.grey[100],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                  ),
                ),

                const SizedBox(height: 14),

                // PASSWORD
                TextField(
                  controller: passC,
                  obscureText: hide,
                  style: TextStyle(color: text),
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(hide
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => hide = !hide),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.black26 : Colors.grey[100],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                  ),
                ),

                const SizedBox(height: 20),

                // REGISTER BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: doRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      "DAFTAR",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // BACK
                TextButton(
                  child: const Text("Sudah punya akun? Login"),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
