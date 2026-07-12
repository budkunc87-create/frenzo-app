import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/feed_screen.dart';

void main() {
  runApp(const FrenzoApp());
}

class FrenzoApp extends StatelessWidget {
  const FrenzoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frenzo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF12091F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6D28D9),
          brightness: Brightness.dark,
        ),
      ),
      home: const _PintuMasuk(),
    );
  }
}

class _PintuMasuk extends StatelessWidget {
  const _PintuMasuk();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: ApiService.sudahLogin(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.data! ? const FeedScreen() : const LoginScreen();
      },
    );
  }
}
