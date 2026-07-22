import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
// Ganti import di bawah sesuai nama file layar kamu yang sebenarnya.
import 'mission_screen.dart';
import 'hasil_screen.dart';
import 'create_user_screen.dart';
import 'data_screen.dart';

class _MenuTile {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final WidgetBuilder screenBuilder;
  const _MenuTile({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.screenBuilder,
  });
}

/// Layar "Menu Utama" — 4 tile: Atur Misi, Hasil, Create User, Data.
/// Sesuai mockup: sapaan di atas + grid 2x2 tile berwarna beda tiap fitur.
/// Catatan: nama user masih hardcode "Jeffie" — ganti dengan data akun
/// yang login (misal dari Firebase Auth / state management kamu).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.userName = 'Jeffie'});

  final String userName;

  static final List<_MenuTile> _tiles = [
    _MenuTile(
      label: 'Atur misi',
      icon: Icons.checklist_rounded,
      iconColor: AppColors.navy,
      bgColor: const Color(0xFFE5E8F5),
      screenBuilder: (_) => const MissionSetupScreen(),
    ),
    _MenuTile(
      label: 'Hasil',
      icon: Icons.show_chart_rounded,
      iconColor: AppColors.teal,
      bgColor: AppColors.tealBg,
      screenBuilder: (_) => const HasilScreen(),
    ),
    _MenuTile(
      label: 'Create user',
      icon: Icons.person_add_alt_1_rounded,
      iconColor: const Color(0xFF92670A),
      bgColor: const Color(0xFFFDF1D6),
      screenBuilder: (_) => const CreateUserScreen(),
    ),
    _MenuTile(
      label: 'Data',
      icon: Icons.storage_rounded,
      iconColor: AppColors.red,
      bgColor: AppColors.redBg,
      screenBuilder: (_) => const DataScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat bertugas,',
                  style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                ),
                const SizedBox(height: 2),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: GridView.builder(
                    itemCount: _tiles.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.35,
                    ),
                    itemBuilder: (context, i) {
                      final tile = _tiles[i];
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: tile.screenBuilder),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF9F5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: tile.bgColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(tile.icon, size: 17, color: tile.iconColor),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                tile.label,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
