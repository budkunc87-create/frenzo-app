import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'https://shortcut.webze.eu.org/api';

class ApiService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> _simpanToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> hapusToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Mobile Safari/537.36',
      'X-Requested-With': 'XMLHttpRequest',
    };
    if (withAuth) {
      final token = await _getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> _post(String endpoint, Map<String, dynamic> body, {bool withAuth = true}) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: await _headers(withAuth: withAuth),
      body: jsonEncode(body),
    );
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> _get(String endpoint) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: await _headers(),
    );
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> login(String email, String sandi) async {
    final hasil = await _post('login.php', {'email': email, 'sandi': sandi}, withAuth: false);
    if (hasil['sukses'] == true) {
      await _simpanToken(hasil['data']['token']);
    }
    return hasil;
  }

  static Future<Map<String, dynamic>> register(String nama, String username, String email, String sandi) async {
    final hasil = await _post('register.php', {
      'nama': nama, 'username': username, 'email': email, 'sandi': sandi,
    }, withAuth: false);
    if (hasil['sukses'] == true) {
      await _simpanToken(hasil['data']['token']);
    }
    return hasil;
  }

  static Future<void> logout() async {
    await _post('logout.php', {});
    await hapusToken();
  }

  static Future<bool> sudahLogin() async {
    final token = await _getToken();
    return token != null;
  }

  static Future<Map<String, dynamic>> ambilFeed({int halaman = 1}) {
    return _get('feed.php?halaman=$halaman');
  }

  static Future<Map<String, dynamic>> toggleSuka(int idPost) {
    return _post('like.php', {'id_post': idPost});
  }

  static Future<Map<String, dynamic>> ambilKomentar(int idPost) {
    return _get('komentar_list.php?id_post=$idPost');
  }

  static Future<Map<String, dynamic>> tambahKomentar(int idPost, String isi) {
    return _post('komentar_tambah.php', {'id_post': idPost, 'isi_komentar': isi});
  }

  static Future<Map<String, dynamic>> toggleIkuti(int idDiikuti) {
    return _post('ikuti.php', {'id_diikuti': idDiikuti});
  }

  static Future<Map<String, dynamic>> ambilProfil({int? idUser}) {
    final query = idUser != null ? '?id_user=$idUser' : '';
    return _get('profil.php$query');
  }
}
