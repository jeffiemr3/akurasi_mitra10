import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class _ReportInfo {
  final String name;
  final String updatedAt;
  const _ReportInfo({required this.name, required this.updatedAt});
}

/// Layar "Data" — daftar laporan yang bisa diexport.
/// Sesuai mockup: list laporan + tombol export data.
/// Catatan: sumber data laporan masih dummy/statis. Kalau nanti mau
/// dihubungkan ke Firebase/WMS/NAV asli, tinggal ganti `_reports` di bawah
/// dengan hasil query yang sesuai.
class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  static const _reports = [
    _ReportInfo(name: 'Report Stock WMS vs NAV', updatedAt: '22/07/2026 07.57'),
    _ReportInfo(name: 'Stock Warehouse by Location', updatedAt: '22/07/2026 07.57'),
    _ReportInfo(name: 'Item Selisih Stock Opname', updatedAt: '22/07/2026 07.57'),
    _ReportInfo(name: 'Stock qty and value', updatedAt: '22/07/2026 07.57'),
  ];

  int _selected = 1;

  void _export() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export "${_reports[_selected].name}" (belum terhubung ke sumber data asli)')),
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
                    _CircleIconButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Data laporan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.builder(
                    itemCount: _reports.length,
                    itemBuilder: (context, i) {
                      final r = _reports[i];
                      final active = i == _selected;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => setState(() => _selected = i),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: active ? const Color(0xFFEBEEFA) : const Color(0xFFFAF9F5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: active ? AppColors.navy : AppColors.line,
                                width: active ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.name,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Update: ${r.updatedAt}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: active ? AppColors.navy : AppColors.inkSoft,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _export,
                    icon: const Icon(Icons.file_download_outlined, size: 17),
                    label: const Text('Export data', style: TextStyle(fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      side: const BorderSide(color: AppColors.line),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
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
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.line),
          color: AppColors.card,
        ),
        child: Icon(icon, size: 15, color: AppColors.ink),
      ),
    );
  }
}
