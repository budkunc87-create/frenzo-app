import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'feed_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _namaCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _sandiCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    setState(() { _loading = true; _error = null; });
    try {
      final hasil = await ApiService.register(
        _namaCtrl.text.trim(),
        _usernameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _sandiCtrl.text.trim(),
      );
      if (hasil['sukses'] == true) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const FeedScreen()),
        );
      } else {
        setState(() => _error = hasil['pesan'] ?? 'Pendaftaran gagal');
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
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text('Daftar Frenzo')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(controller: _namaCtrl, style: const TextStyle(color: Colors.white), decoration: _dek('Nama lengkap')),
              const SizedBox(height: 16),
              TextField(controller: _usernameCtrl, style: const TextStyle(color: Colors.white), decoration: _dek('Username')),
              const SizedBox(height: 16),
              TextField(controller: _emailCtrl, style: const TextStyle(color: Colors.white), decoration: _dek('Email')),
              const SizedBox(height: 16),
              TextField(controller: _sandiCtrl, obscureText: true, style: const TextStyle(color: Colors.white), decoration: _dek('Kata sandi (min. 6 karakter)')),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _register,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6D28D9), padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Daftar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dek(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      );
}
