import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class _CategoryAssignment {
  final String category;
  String? assignedTo;
  _CategoryAssignment({required this.category, this.assignedTo});
}

/// Layar "Atur Misi" — admin menugaskan tiap kategori ke satu user.
/// Catatan: daftar kategori & user masih dummy/statis. Kalau nanti mau
/// dihubungkan ke data asli (misal dari Firestore/API), tinggal ganti
/// `_assignments` dan `_availableUsers` di bawah dengan hasil query.
class MissionSetupScreen extends StatefulWidget {
  const MissionSetupScreen({super.key});

  @override
  State<MissionSetupScreen> createState() => _MissionSetupScreenState();
}

class _MissionSetupScreenState extends State<MissionSetupScreen> {
  static const _availableUsers = [
    'Sahat Sinaga',
    'Rina Purnama',
    'Andi Wijaya',
    'Jeffie Mitrahman',
  ];

  final _assignments = [
    _CategoryAssignment(category: 'Floring & Wall', assignedTo: 'Sahat Sinaga'),
    _CategoryAssignment(category: 'Electrical & Lighting', assignedTo: 'Rina Purnama'),
    _CategoryAssignment(category: 'Hand Tools', assignedTo: 'Andi Wijaya'),
    _CategoryAssignment(category: 'Sanitary & Plumbing'),
  ];

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Penugasan disimpan (belum terhubung ke sumber data asli)')),
    );
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
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.maybePop(context),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.line),
                          color: AppColors.card,
                        ),
                        child: const Icon(Icons.arrow_back, size: 15, color: AppColors.ink),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Atur misi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Padding(
                  padding: EdgeInsets.only(left: 40),
                  child: Text(
                    'Tugaskan tiap kategori ke satu akun',
                    style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.separated(
                    itemCount: _assignments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final a = _assignments[i];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF9F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                a.category,
                                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColors.ink),
                              ),
                            ),
                            DropdownButton<String>(
                              value: a.assignedTo,
                              hint: const Text('Pilih user', style: TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                              underline: const SizedBox(),
                              style: const TextStyle(fontSize: 12.5, color: AppColors.navy, fontWeight: FontWeight.w500),
                              items: _availableUsers
                                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                                  .toList(),
                              onChanged: (val) => setState(() => a.assignedTo = val),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('Simpan penugasan', style: TextStyle(fontWeight: FontWeight.w600)),
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
