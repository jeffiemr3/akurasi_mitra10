import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/realtime_db_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'tambah_user_screen.dart';

/// Porting dari src/screens/ManajemenUserScreen.tsx — list user + search +
/// toggle status active/idle + hapus user (kecuali akun `admin`).
class ManajemenUserScreen extends StatefulWidget {
  const ManajemenUserScreen({super.key});

  @override
  State<ManajemenUserScreen> createState() => _ManajemenUserScreenState();
}

class _ManajemenUserScreenState extends State<ManajemenUserScreen> {
  final _db = RealtimeDbService.instance;
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(AppUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus User Ini?'),
        content: const Text(
            'Akun ini tidak akan dapat digunakan lagi untuk login.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _db.deleteUser(user.id);
    }
  }

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
                children: [
                  BackCircleButton(onPressed: () => Navigator.of(context).pop()),
                  const SizedBox(width: 10),
                  const Expanded(child: ScreenLabel('Manajemen User')),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TambahUserScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.person_add_alt_1, size: 16),
                    label: const Text('User Baru'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Manajemen User',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Daftar akun auditor dan administrator Mitra10',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.inkSoft),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _search = v),
                        decoration: InputDecoration(
                          hintText:
                              'Cari berdasarkan nama, username, atau kategori...',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          filled: true,
                          fillColor: AppColors.fieldFill,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.line),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: StreamBuilder<List<AppUser>>(
                          stream: _db.watchUsers(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            final query = _search.toLowerCase();
                            final users = snapshot.data!
                                .where((u) =>
                                    u.name.toLowerCase().contains(query) ||
                                    u.username.toLowerCase().contains(query) ||
                                    (u.category ?? '')
                                        .toLowerCase()
                                        .contains(query))
                                .toList();

                            if (users.isEmpty) {
                              return const Center(
                                child: Text(
                                  'Belum ada user.',
                                  style: TextStyle(color: AppColors.inkSoft),
                                ),
                              );
                            }

                            return ListView.separated(
                              itemCount: users.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) =>
                                  _UserRow(
                                user: users[index],
                                onToggleStatus: () {
                                  final u = users[index];
                                  final newStatus =
                                      u.status == 'active' ? 'idle' : 'active';
                                  _db.updateUser(u.id, {'status': newStatus});
                                },
                                onDelete: () => _confirmDelete(users[index]),
                              ),
                            );
                          },
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

class _UserRow extends StatelessWidget {
  final AppUser user;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const _UserRow({
    required this.user,
    required this.onToggleStatus,
    required this.onDelete,
  });

  String get _initials {
    final parts = user.name.trim().split(RegExp(r'\s+'));
    final letters = parts.map((p) => p.isNotEmpty ? p[0] : '').join();
    return letters.length > 2 ? letters.substring(0, 2) : letters;
  }

  @override
  Widget build(BuildContext context) {
    final isActive = user.status == 'active';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F5),
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.avatarNavyBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _initials.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: user.isAdmin
                            ? AppColors.amberBg
                            : AppColors.tealBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: user.isAdmin
                              ? AppColors.amber
                              : AppColors.teal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '@${user.username} · ${user.isAdmin ? 'Admin · semua kategori' : (user.category ?? '-')}',
                  style: const TextStyle(
                      fontSize: 11.5, color: AppColors.inkSoft),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onToggleStatus,
            style: TextButton.styleFrom(
              backgroundColor:
                  isActive ? AppColors.tealBg : const Color(0xFFE5E7EB),
              foregroundColor:
                  isActive ? AppColors.teal : const Color(0xFF4B5563),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            icon: const Icon(Icons.power_settings_new, size: 13),
            label: Text(user.status,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          if (user.username != 'admin')
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.coral, size: 19),
              tooltip: 'Hapus user',
            ),
        ],
      ),
    );
  }
}
