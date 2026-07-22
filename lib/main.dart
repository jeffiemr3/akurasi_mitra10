import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _seedDefaultAdmin();
  runApp(const AkurasiApp());
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
