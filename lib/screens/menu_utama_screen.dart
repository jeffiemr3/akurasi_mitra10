import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'data_screen.dart';
import 'hasil_screen.dart';
import 'manajemen_user_screen.dart';
import 'mission_setup_screen.dart';
// Sesuaikan dengan nama file & class layar login/buat-akun kamu yang sebenarnya.
import 'login_screen.dart';

class MenuUtamaScreen extends StatelessWidget {
  final String name;

  const MenuUtamaScreen({super.key, required this.name});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar akun?'),
        content: const Text('Kamu akan kembali ke halaman login.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Keluar', style: TextStyle(color: AppColors.coral)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MENU UTAMA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.inkSoft,
                    ),
                  ),
                  InkWell(
                    onTap: () => _confirmLogout(context),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.card,
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        size: 16,
                        color: AppColors.coral,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selamat bertugas,',
                        style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
                      ),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.15,
                          children: [
                            _MenuCard(
                              label: 'Atur misi',
                              icon: Icons.checklist_rounded,
                              iconBg: AppColors.avatarNavyBg,
                              iconColor: AppColors.navy,
                              enabled: true,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const MissionSetupScreen(),
                                  ),
                                );
                              },
                            ),
                            _MenuCard(
                              label: 'Hasil',
                              icon: Icons.show_chart_rounded,
                              iconBg: AppColors.tealBg,
                              iconColor: AppColors.teal,
                              enabled: true,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const HasilScreen(),
                                  ),
                                );
                              },
                            ),
                            _MenuCard(
                              label: 'Create user',
                              icon: Icons.person_add_alt_1_rounded,
                              iconBg: AppColors.amberBg,
                              iconColor: AppColors.amber,
                              enabled: true,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ManajemenUserScreen(),
                                  ),
                                );
                              },
                            ),
                            _MenuCard(
                              label: 'Data',
                              icon: Icons.storage_rounded,
                              iconBg: AppColors.coralBg,
                              iconColor: AppColors.coral,
                              enabled: true,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const DataScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final bool enabled;
  final VoidCallback? onTap;

  const _MenuCard({
    required this.label,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: enabled ? iconBg : AppColors.grayChip,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: enabled ? iconColor : AppColors.inkSoft.withOpacity(0.5),
            ),
          ),
          const Spacer(),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: enabled ? AppColors.ink : AppColors.inkSoft,
            ),
          ),
        ],
      ),
    );

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: enabled
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: content,
            )
          : content,
    );
  }
}
