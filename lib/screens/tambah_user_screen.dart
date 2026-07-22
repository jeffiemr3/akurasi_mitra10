import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../theme/app_colors.dart';

class TambahUserScreen extends StatefulWidget {
  const TambahUserScreen({super.key});

  @override
  State<TambahUserScreen> createState() => _TambahUserScreenState();
}

class _TambahUserScreenState extends State<TambahUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _role = 'admin';
  String? _category;
  bool _saving = false;
  bool _obscurePassword = true;

  static const _categories = [
    'Floring & Wall',
    'Electrical & Lighting',
    'Hand Tools',
    'Sanitary & Plumbing',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_role == 'client' && _category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori untuk role Client')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final ref = FirebaseDatabase.instance.ref('users').push();
      await ref.set({
        'name': _nameCtrl.text.trim(),
        'username': _usernameCtrl.text.trim(),
        'password': _passwordCtrl.text.trim(),
        'role': _role,
        'category': _role == 'client' ? _category : null,
        'status': 'idle',
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Tambah user',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.line),
                          ),
                          child: const Icon(Icons.close, size: 14, color: AppColors.inkSoft),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Isi data akun baru',
                      style: TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                  const SizedBox(height: 20),
                  _label('Nama'),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: _decoration('Nama lengkap'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  _label('Nama user'),
                  TextFormField(
                    controller: _usernameCtrl,
                    decoration: _decoration('nama.user'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Nama user wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  _label('Password'),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    decoration: _decoration('Minimal 6 karakter').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          size: 18,
                          color: AppColors.inkSoft,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().length < 6)
                        ? 'Password minimal 6 karakter'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _label('Peran'),
                  const SizedBox(height: 4),
                  _RoleTile(
                    title: 'Admin',
                    desc: 'Akses semua kategori & laporan',
                    selected: _role == 'admin',
                    onTap: () => setState(() => _role = 'admin'),
                  ),
                  const SizedBox(height: 8),
                  _RoleTile(
                    title: 'Client',
                    desc: 'Hanya akses 1 kategori yang ditugaskan',
                    selected: _role == 'client',
                    onTap: () => setState(() => _role = 'client'),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 180),
                    alignment: Alignment.topCenter,
                    child: _role == 'client'
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: DropdownButtonFormField<String>(
                              initialValue: _category,
                              decoration: _decoration('Pilih kategori...'),
                              items: _categories
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                  .toList(),
                              onChanged: (v) => setState(() => _category = v),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Simpan user',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
      );

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.fieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.navy, width: 1.5),
        ),
      );
}

class _RoleTile extends StatelessWidget {
  final String title;
  final String desc;
  final bool selected;
  final VoidCallback onTap;

  const _RoleTile({
    required this.title,
    required this.desc,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? AppColors.navy : AppColors.line),
          borderRadius: BorderRadius.circular(10),
          color: selected ? const Color(0xFFF4F6FC) : Colors.transparent,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 18,
              height: 18,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.navy : AppColors.fieldFill,
                border: Border.all(
                  color: selected ? AppColors.navy : AppColors.line,
                  width: 1.5,
                ),
              ),
              child: selected ? const Icon(Icons.check, size: 11, color: Colors.white) : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ink)),
                  Text(desc,
                      style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
