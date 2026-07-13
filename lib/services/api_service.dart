import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as ioc;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'https://shortcut.webze.eu.org/api';

class ApiService {
  static http.Client? _client;
  static String? _resolvedIp;
  static String debugInfo = 'belum dicoba';

  static Future<String?> _resolveIpViaDoH(String hostname) async {
    try {
      final resp = await http.get(
        Uri.parse('https://dns.google/resolve?name=$hostname&type=A'),
        headers: {'Accept': 'application/dns-json'},
      ).timeout(const Duration(seconds: 8));
      final data = jsonDecode(resp.body);
      final answers = data['Answer'] as List?;
      if (answers != null) {
        for (final a in answers) {
          if (a['type'] == 1) {
            debugInfo = 'DoH sukses, IP=${a['data']}';
            return a['data'];
          }
        }
      }
      debugInfo = 'DoH sukses tapi tidak ada record A. Status=${data['Status']}, respons=${resp.body}';
    } catch (e) {
      debugInfo = 'DoH gagal: $e';
    }
    return null;
  }

  static Future<http.Client> _getClient() async {
    if (_client != null) return _client!;

    final hostname = Uri.parse(baseUrl).host;
    _resolvedIp = await _resolveIpViaDoH(hostname);

    if (_resolvedIp == null) {
      _client = http.Client();
      return _client!;
    }

    final httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) => true;
    httpClient.connectionFactory = (Uri uri, String? proxyHost, int? proxyPort) {
      return SecureSocket.startConnect(_resolvedIp!, uri.port);
    };
    _client = ioc.IOClient(httpClient);
    return _client!;
  }

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
    final client = await _getClient();
    final resp = await client.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: await _headers(withAuth: withAuth),
      body: jsonEncode(body),
    );
    try {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (e) {
      final potongan = resp.body.length > 500 ? resp.body.substring(0, 500) : resp.body;
      throw Exception('Status HTTP ${resp.statusCode}. Isi respons:\n$potongan');
    }
  }

  static Future<Map<String, dynamic>> _get(String endpoint) async {
    final client = await _getClient();
    final resp = await client.get(
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
