import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/app_user.dart';
import 'screens/login_username_screen.dart';
import 'screens/menu_utama_screen.dart';
import 'services/realtime_db_service.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await RealtimeDbService.instance.seedInitialAdminIfEmpty();
  runApp(const AkurasiApp());
}

class AkurasiApp extends StatelessWidget {
  const AkurasiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akurasi Mitra10',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.navy,
          primary: AppColors.navy,
        ),
        fontFamily: 'Roboto',
      ),
      home: const _AuthGate(),
    );
  }
}

/// Gerbang autentikasi sederhana: kalau belum login tampilkan alur
/// login (username -> password), kalau sudah login tampilkan menu utama.
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  AppUser? _currentUser;

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return StreamBuilder<List<AppUser>>(
        stream: RealtimeDbService.instance.watchUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              backgroundColor: AppColors.bg,
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return LoginUsernameScreen(
            users: snapshot.data!,
            onLoginSuccess: (user) {
              setState(() => _currentUser = user);
              // Kembali ke root stack (menu utama) setelah login sukses.
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          );
        },
      );
    }

    return MenuUtamaScreen(
      currentUser: _currentUser!,
      onLogout: () => setState(() => _currentUser = null),
    );
  }
}
