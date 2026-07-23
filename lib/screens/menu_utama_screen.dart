import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'manajemen_user_screen.dart';
import 'mission_setup_screen.dart';
import 'upload_data_screen.dart';

/// Menu utama sederhana untuk admin — pusat navigasi ke 3 fitur inti yang
/// jadi fokus perbaikan: Manajemen User, Upload Data, dan Atur Misi.
/// (Menggantikan MenuUtamaScreen.tsx yang tadinya juga berisi menu Hasil/Data
/// laporan — disederhanakan sesuai permintaan.)
class MenuUtamaScreen extends StatelessWidget {
  final AppUser currentUser;
  final VoidCallback onLogout;

  const MenuUtamaScreen({
    super.key,
    required this.currentUser,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AKURASI MITRA10',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppColors.inkSoft,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Halo, ${currentUser.name}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout, color: AppColors.coral),
                    tooltip: 'Keluar',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _MenuTile(
                      icon: Icons.people_alt_outlined,
                      title: 'Manajemen User',
                      subtitle: 'Kelola akun auditor & administrator',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ManajemenUserScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MenuTile(
                      icon: Icons.upload_file_outlined,
                      title: 'Upload Data',
                      subtitle: 'Masukkan data stok WMS vs NAV (Excel/paste/manual)',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const UploadDataScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MenuTile(
                      icon: Icons.assignment_turned_in_outlined,
                      title: 'Atur / Beri Misi',
                      subtitle: 'Tugaskan kategori audit ke auditor',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MissionSetupScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.avatarNavyBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.navy),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.inkSoft),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.inkSoft),
          ],
        ),
      ),
    );
  }
}
