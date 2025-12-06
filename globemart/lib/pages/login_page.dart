import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import 'register_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userC = TextEditingController();
  final passC = TextEditingController();
  bool hide = true;

  void doLogin() {
    if (userC.text.isEmpty || passC.text.isEmpty) {
      _snack("Username & Password wajib diisi");
      return;
    }

    final ok = HiveService.login(userC.text, passC.text);
    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      _snack("Login gagal. Periksa username/password");
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

                // LOGO
                const Icon(Icons.storefront,
                    size: 60, color: Colors.indigo),
                const SizedBox(height: 10),
                Text("GlobeMart",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: text,
                    )),
                const SizedBox(height: 4),
                Text("Login ke akun anda",
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
                      icon: Icon(
                          hide ? Icons.visibility_off : Icons.visibility),
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

                const SizedBox(height: 22),

                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: doLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      "LOGIN",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // LINK REGISTER
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  ),
                  child: const Text("Belum punya akun? Daftar"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
