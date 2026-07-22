import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/app_user.dart';
import '../theme/app_colors.dart';
import 'tambah_user_screen.dart';

class ManajemenUserScreen extends StatefulWidget {
  const ManajemenUserScreen({super.key});

  @override
  State<ManajemenUserScreen> createState() => _ManajemenUserScreenState();
}

class _ManajemenUserScreenState extends State<ManajemenUserScreen> {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');

  List<AppUser> _parseUsers(DataSnapshot snapshot) {
    final data = snapshot.value;
    if (data == null || data is! Map) return [];
    final map = Map<dynamic, dynamic>.from(data);
    final list = map.entries
        .map((e) => AppUser.fromMap(
              e.key.toString(),
              Map<dynamic, dynamic>.from(e.value as Map),
            ))
        .toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  Future<void> _confirmDelete(AppUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus user?'),
        content: Text(
          'Akun "${user.name}" akan dihapus permanen dan tidak bisa login lagi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.coral),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _usersRef.child(user.id).remove();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.name} dihapus')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: $e')),
      );
    }
  }

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
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _CircleIconButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Manajemen user',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    _AddUserButton(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TambahUserScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                StreamBuilder<DatabaseEvent>(
                  stream: _usersRef.onValue,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                      return const Text(
                        '0 akun aktif · 1 kategori per akun',
                        style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                      );
                    }
                    final users = _parseUsers(snapshot.data!.snapshot);
                    final activeCount = users.where((u) => u.isActive).length;
                    return Text(
                      '$activeCount akun aktif · 1 kategori per akun',
                      style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<DatabaseEvent>(
                    stream: _usersRef.onValue,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.navy),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Gagal memuat data: ${snapshot.error}'),
                        );
                      }
                      final value = snapshot.data?.snapshot.value;
                      if (value == null) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              'Belum ada user.\nTap "Tambah" untuk membuat akun.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.inkSoft, fontSize: 13),
                            ),
                          ),
                        );
                      }
                      final users = _parseUsers(snapshot.data!.snapshot);
                      return ListView.separated(
                        itemCount: users.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: AppColors.line),
                        itemBuilder: (context, i) => _UserRow(
                          user: users[i],
                          onDelete: () => _confirmDelete(users[i]),
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

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color? iconColor;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.size = 30,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.line),
          color: AppColors.card,
        ),
        child: Icon(icon, size: size * 0.48, color: iconColor ?? AppColors.ink),
      ),
    );
  }
}

class _AddUserButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddUserButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 7, 13, 7),
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 13, color: Colors.white),
            SizedBox(width: 5),
            Text(
              'Tambah',
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  final AppUser user;
  final VoidCallback onDelete;
  const _UserRow({required this.user, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: user.isActive ? AppColors.avatarNavyBg : AppColors.grayChip,
            child: Text(
              user.initials,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.username,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.inkSoft,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.grayChip,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.categoryLabel,
                    style: const TextStyle(fontSize: 10.5, color: AppColors.inkSoft),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: user.isActive ? AppColors.tealBg : AppColors.grayChip,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.isActive ? 'Aktif' : 'Belum masuk',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: user.isActive ? AppColors.teal : AppColors.inkSoft,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _CircleIconButton(
            icon: Icons.delete_outline,
            size: 26,
            iconColor: AppColors.inkSoft,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}
