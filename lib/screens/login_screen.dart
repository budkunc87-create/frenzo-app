import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'feed_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _sandiCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      final hasil = await ApiService.login(_emailCtrl.text.trim(), _sandiCtrl.text.trim());
      if (hasil['sukses'] == true) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const FeedScreen()),
        );
      } else {
        setState(() => _error = hasil['pesan'] ?? 'Login gagal');
      }
    } catch (e) {
      setState(() => _error = 'Tidak bisa terhubung ke server');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12091F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Frenzo', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Terhubung dengan teman', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 32),
              TextField(
                controller: _emailCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _dekorasiInput('Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _sandiCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _dekorasiInput('Kata sandi'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D28D9),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Masuk', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: const Text('Belum punya akun? Daftar', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dekorasiInput(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}
