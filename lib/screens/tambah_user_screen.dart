import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/category_assignment.dart';
import '../services/realtime_db_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

/// Porting dari src/screens/TambahUserScreen.tsx — form tambah user baru
/// (nama, username, password, role admin/client, kategori jika client).
class TambahUserScreen extends StatefulWidget {
  const TambahUserScreen({super.key});

  @override
  State<TambahUserScreen> createState() => _TambahUserScreenState();
}

class _TambahUserScreenState extends State<TambahUserScreen> {
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _role = 'client';
  String? _category;
  String? _error;
  bool _success = false;
  bool _saving = false;

  final _db = RealtimeDbService.instance;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(List<CategoryAssignment> categories) async {
    if (_nameCtrl.text.trim().isEmpty ||
        _usernameCtrl.text.trim().isEmpty ||
        _passwordCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Semua kolom bertanda wajib diisi');
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    final newUser = AppUser(
      id: '',
      name: _nameCtrl.text.trim(),
      username: _usernameCtrl.text.trim().toLowerCase(),
      password: _passwordCtrl.text.trim(),
      role: _role,
      category: _role == 'admin' ? null : _category,
      status: 'active',
    );

    await _db.addUser(newUser);

    if (!mounted) return;
    setState(() {
      _saving = false;
      _success = true;
    });

    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) Navigator.of(context).pop();
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
                  const ScreenLabel('Tambah User'),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: StreamBuilder<List<CategoryAssignment>>(
                  stream: _db.watchCategories(),
                  builder: (context, snapshot) {
                    final categories = snapshot.data ?? [];
                    final categoryNames =
                        categories.map((c) => c.categoryName).toList();
                    _category ??=
                        categoryNames.isNotEmpty ? categoryNames.first : null;

                    return SingleChildScrollView(
                      child: AppCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tambah User Baru',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Buat akun auditor atau administrator baru',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.inkSoft),
                            ),
                            const SizedBox(height: 20),
                            AppTextField(
                              controller: _nameCtrl,
                              label: 'Nama Lengkap *',
                              hint: 'Misal: Sahat Sinaga',
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: _usernameCtrl,
                              label: 'Username *',
                              hint: 'Misal: sahat.sinaga',
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: _passwordCtrl,
                              label: 'Kata Sandi *',
                              hint: 'Masukkan kata sandi',
                              obscure: true,
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Role Akses',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.inkSoft),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: _RoleOption(
                                    label: 'Auditor Client',
                                    selected: _role == 'client',
                                    onTap: () =>
                                        setState(() => _role = 'client'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _RoleOption(
                                    label: 'Admin Store',
                                    selected: _role == 'admin',
                                    onTap: () =>
                                        setState(() => _role = 'admin'),
                                  ),
                                ),
                              ],
                            ),
                            if (_role == 'client') ...[
                              const SizedBox(height: 14),
                              const Text(
                                'Kategori Utama',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.inkSoft),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: _category,
                                items: categoryNames
                                    .map((c) => DropdownMenuItem(
                                        value: c, child: Text(c)))
                                    .toList(),
                                onChanged: (v) => setState(() => _category = v),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.fieldFill,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        const BorderSide(color: AppColors.line),
                                  ),
                                ),
                                hint: const Text('Belum ada kategori'),
                              ),
                            ],
                            if (_error != null) ...[
                              const SizedBox(height: 14),
                              Text(
                                _error!,
                                style: const TextStyle(
                                    color: AppColors.coral,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                            if (_success) ...[
                              const SizedBox(height: 14),
                              const StatusBanner(
                                message: 'User berhasil didaftarkan!',
                                success: true,
                              ),
                            ],
                            const SizedBox(height: 20),
                            PrimaryButton(
                              label: 'Simpan User',
                              loading: _saving,
                              onPressed: () => _handleSubmit(categories),
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
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.avatarNavyBg : Colors.transparent,
          border: Border.all(
              color: selected ? AppColors.navy : AppColors.line),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: selected ? AppColors.navy : AppColors.inkSoft,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.navy : AppColors.inkSoft,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
