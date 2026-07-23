import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/category_assignment.dart';
import '../services/realtime_db_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

/// Porting dari src/screens/MissionSetupScreen.tsx (tab "Penugasan Auditor")
/// — menugaskan tiap kategori hasil upload data ke seorang auditor aktif.
/// Tab "Ringkasan Per Kategori" (chart HIT/MISS/OVER) tidak disertakan dulu
/// karena bukan bagian dari 4 fokus perbaikan saat ini.
class MissionSetupScreen extends StatefulWidget {
  const MissionSetupScreen({super.key});

  @override
  State<MissionSetupScreen> createState() => _MissionSetupScreenState();
}

class _MissionSetupScreenState extends State<MissionSetupScreen> {
  final _db = RealtimeDbService.instance;
  bool _savedMessageVisible = false;

  Future<void> _handleAssign(CategoryAssignment cat, String? username) async {
    await _db.assignCategoryToUser(cat.id, username);
    if (username != null) {
      // Sinkronkan kategori terpilih ke profil user (dipakai user itu login).
      final users = await _db.watchUsers().first;
      for (final u in users) {
        if (u.username == username && u.category != cat.categoryName) {
          await _db.updateUser(u.id, {'category': cat.categoryName});
        }
      }
    }
    setState(() => _savedMessageVisible = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _savedMessageVisible = false);
    });
  }

  Future<void> _showAddCategoryDialog() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Kategori Baru'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nama kategori (mis: Plumbing, Electronics)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      final newCat = CategoryAssignment(
        id: 'c-${DateTime.now().millisecondsSinceEpoch}',
        categoryName: name,
        assignedUsername: null,
        status: 'available',
        itemCount: 0,
      );
      await _db.upsertCategory(newCat);
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
                  const Expanded(child: ScreenLabel('Atur Misi')),
                  IconButton(
                    onPressed: _showAddCategoryDialog,
                    icon: const Icon(Icons.add_circle_outline,
                        color: AppColors.navy),
                    tooltip: 'Tambah kategori',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Atur Misi & Penugasan Kategori',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Tugaskan kategori hasil upload data ke auditor yang aktif',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.inkSoft),
                      ),
                      const SizedBox(height: 14),
                      if (_savedMessageVisible)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: StatusBanner(
                            message: 'Penugasan misi berhasil disimpan!',
                            success: true,
                          ),
                        ),
                      Expanded(
                        child: StreamBuilder<List<AppUser>>(
                          stream: _db.watchUsers(),
                          builder: (context, userSnapshot) {
                            final availableUsers = (userSnapshot.data ?? [])
                                .where((u) => u.status == 'active')
                                .toList();

                            return StreamBuilder<List<CategoryAssignment>>(
                              stream: _db.watchCategories(),
                              builder: (context, catSnapshot) {
                                if (!catSnapshot.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                final categories = catSnapshot.data!;
                                if (categories.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      'Belum ada kategori. Upload data stok dulu\natau tambah kategori manual.',
                                      textAlign: TextAlign.center,
                                      style:
                                          TextStyle(color: AppColors.inkSoft),
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  itemCount: categories.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final cat = categories[index];
                                    return _CategoryRow(
                                      category: cat,
                                      availableUsers: availableUsers,
                                      onChanged: (username) =>
                                          _handleAssign(cat, username),
                                    );
                                  },
                                );
                              },
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

class _CategoryRow extends StatelessWidget {
  final CategoryAssignment category;
  final List<AppUser> availableUsers;
  final void Function(String? username) onChanged;

  const _CategoryRow({
    required this.category,
    required this.availableUsers,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Pastikan value dropdown valid (ada di daftar), kalau tidak fallback null.
    final validUsernames = availableUsers.map((u) => u.username).toSet();
    final currentValue = (category.assignedUsername != null &&
            validUsernames.contains(category.assignedUsername))
        ? category.assignedUsername
        : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F5),
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.categoryName,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${category.itemCount} items audit',
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.inkSoft),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: currentValue,
            hint: const Text('-- Pilih user --', style: TextStyle(fontSize: 12)),
            underline: const SizedBox(),
            items: availableUsers
                .map((u) => DropdownMenuItem(
                      value: u.username,
                      child: Text('${u.name} (${u.username})',
                          style: const TextStyle(fontSize: 12.5)),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
