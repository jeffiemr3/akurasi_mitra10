import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? initError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await _seedDefaultAdmin();
  } catch (e) {
    // Kalau Firebase gagal init (misal appId/messagingSenderId di
    // firebase_options.dart belum diisi nilai asli dari Firebase Console),
    // jangan biarkan app mati diam-diam jadi layar putih kosong.
    // Tampilkan pesan errornya supaya gampang di-debug.
    initError = e;
    debugPrint('Gagal inisialisasi Firebase: $e');
  }

  runApp(initError == null ? const AkurasiApp() : _InitErrorApp(error: initError));
}

/// Ditampilkan kalau Firebase.initializeApp gagal, supaya user/dev tahu
/// penyebabnya lewat pesan di layar, bukan layar putih kosong tanpa info.
class _InitErrorApp extends StatelessWidget {
  final Object error;
  const _InitErrorApp({required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Gagal memuat aplikasi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kemungkinan konfigurasi Firebase (firebase_options.dart) belum '
                    'lengkap — pastikan appId dan messagingSenderId sudah diisi nilai '
                    'asli dari Firebase Console, bukan placeholder.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: Colors.black38),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kalau node "users" masih kosong sama sekali (misalnya pertama kali app
/// dijalankan), otomatis buatkan 1 akun admin default: admin / admin.
/// Setelah ada minimal 1 user, fungsi ini tidak akan menambah apa-apa lagi.
Future<void> _seedDefaultAdmin() async {
  try {
    final usersRef = FirebaseDatabase.instance.ref('users');
    final snapshot = await usersRef.get();
    if (snapshot.exists && snapshot.value != null) return;

    await usersRef.push().set({
      'name': 'Admin',
      'username': 'admin',
      'password': 'admin',
      'role': 'admin',
      'category': null,
      'status': 'active',
    });
  } catch (e) {
    // Kalau gagal (misal belum ada koneksi/izin), biarkan saja —
    // aplikasi tetap jalan, tinggal buat user manual lewat Firebase Console.
    debugPrint('Gagal seed admin default: $e');
  }
}

class AkurasiApp extends StatelessWidget {
  const AkurasiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akurasi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.navy),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
