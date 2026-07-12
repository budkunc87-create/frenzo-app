import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/postingan.dart';
import 'login_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Postingan> _daftar = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _muatFeed();
  }

  Future<void> _muatFeed() async {
    setState(() { _loading = true; _error = null; });
    try {
      final hasil = await ApiService.ambilFeed();
      if (hasil['sukses'] == true) {
        final List data = hasil['data']['postingan'];
        setState(() => _daftar = data.map((e) => Postingan.fromJson(e)).toList());
      } else {
        setState(() => _error = hasil['pesan']);
      }
    } catch (e) {
      setState(() => _error = 'Tidak bisa terhubung ke server');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleSuka(Postingan p) async {
    setState(() {
      p.sudahSuka = !p.sudahSuka;
      p.totalSuka += p.sudahSuka ? 1 : -1;
    });
    await ApiService.toggleSuka(p.idPost);
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12091F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Frenzo'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
              : RefreshIndicator(
                  onRefresh: _muatFeed,
                  child: ListView.builder(
                    itemCount: _daftar.length,
                    itemBuilder: (context, i) => _kartuPost(_daftar[i]),
                  ),
                ),
    );
  }

  Widget _kartuPost(Postingan p) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF6D28D9),
                child: Text(p.namaLengkap.isNotEmpty ? p.namaLengkap[0].toUpperCase() : '?'),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.namaLengkap, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('@${p.username}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(p.isiPost, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                icon: Icon(p.sudahSuka ? Icons.favorite : Icons.favorite_border, color: p.sudahSuka ? Colors.pinkAccent : Colors.white54),
                onPressed: () => _toggleSuka(p),
              ),
              Text('${p.totalSuka}', style: const TextStyle(color: Colors.white54)),
              const SizedBox(width: 16),
              const Icon(Icons.chat_bubble_outline, color: Colors.white54, size: 20),
              const SizedBox(width: 6),
              Text('${p.totalKomen}', style: const TextStyle(color: Colors.white54)),
            ],
          ),
        ],
      ),
    );
  }
}
