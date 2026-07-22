import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as xls;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Layar "Upload Data" — pilih file XLSX (hit/miss/over), lalu simpan
/// hasilnya ke Firebase Realtime Database di node `categories`.
/// Struktur yang tersimpan sama dengan yang dipakai layar kunci-kategori:
///   categories/{catId}/name
///   categories/{catId}/items   (list item: code, name, qtySistem, qtyFisik, status)
///   categories/{catId}/status  ('available' setelah upload baru)
///   categories/{catId}/lockedBy / lockedAt
class UploadDataScreen extends StatefulWidget {
  const UploadDataScreen({super.key});

  @override
  State<UploadDataScreen> createState() => _UploadDataScreenState();
}

class _UploadDataScreenState extends State<UploadDataScreen> {
  bool _loading = false;
  String? _statusMessage;
  bool _success = false;

  String _normHeader(String? h) =>
      (h ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  Future<void> _pickAndUpload() async {
    setState(() {
      _loading = true;
      _statusMessage = null;
      _success = false;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );
      if (result == null || result.files.single.bytes == null) {
        setState(() => _loading = false);
        return;
      }

      final bytes = result.files.single.bytes!;
      final excelFile = xls.Excel.decodeBytes(bytes);

      // catId -> {name, items}
      final Map<String, Map<String, dynamic>> grouped = {};

      for (final sheetName in excelFile.tables.keys) {
        final sheet = excelFile.tables[sheetName]!;
        final rows = sheet.rows;

        // Scan sampai 30 baris untuk cari baris header asli
        // (laporan asli biasanya ada baris info/judul di atas header).
        int headerRowIdx = -1;
        List<String> headerRow = [];
        for (int i = 0; i < rows.length && i < 30; i++) {
          final cells = rows[i].map((c) => c?.value?.toString() ?? '').toList();
          final normalized = cells.map(_normHeader).toList();
          final hasItemNo = normalized.any(
              (c) => ['itemno', 'kodeitem', 'sku', 'itemcode', 'kodebarang'].contains(c));
          final hasName = normalized
              .any((c) => ['itemname', 'namaitem', 'nama', 'namabarang'].contains(c));
          if (hasItemNo && hasName) {
            headerRowIdx = i;
            headerRow = cells;
            break;
          }
        }
        if (headerRowIdx == -1) continue;

        int idxOf(List<String> candidates) {
          for (int c = 0; c < headerRow.length; c++) {
            if (candidates.contains(_normHeader(headerRow[c]))) return c;
          }
          return -1;
        }

        final iCategory = idxOf(['kategori', 'category', 'kat']);
        final iCode = idxOf(['itemno', 'kodeitem', 'kode', 'sku', 'itemcode', 'kodebarang']);
        final iName = idxOf(['itemname', 'namaitem', 'nama', 'namabarang']);
        final iQtySys = idxOf(
            ['endingstocknav', 'stocknav', 'qtysistem', 'qtysystem', 'stocksistem', 'qtynav']);
        final iQtyFisik = idxOf(
            ['endingstockwms', 'stockwms', 'qtyfisik', 'qtyreal', 'stockfisik', 'qtycount', 'qtywms']);
        final iStatus = idxOf(['hitmiss', 'status', 'hasil', 'result']);

        for (int r = headerRowIdx + 1; r < rows.length; r++) {
          final row = rows[r];
          String cellStr(int idx) {
            if (idx < 0 || idx >= row.length) return '';
            return row[idx]?.value?.toString() ?? '';
          }

          num? cellNum(int idx) {
            if (idx < 0 || idx >= row.length) return null;
            final v = row[idx]?.value;
            if (v == null) return null;
            if (v is num) return v;
            return num.tryParse(v.toString());
          }

          final code = cellStr(iCode).trim();
          if (code.isEmpty) continue; // lewati baris kosong/penutup

          final catRaw = iCategory >= 0 ? cellStr(iCategory).trim() : '';
          final catName = catRaw.isEmpty ? 'TANPA KATEGORI' : catRaw;
          final catId = catName
              .replaceAll(RegExp(r'[.#$\[\]/]'), '_')
              .replaceAll(RegExp(r'\s+'), '_');

          final qSys = cellNum(iQtySys);
          final qFis = cellNum(iQtyFisik);
          String status = iStatus >= 0 ? cellStr(iStatus).trim().toUpperCase() : '';
          if (status.isEmpty && qSys != null && qFis != null) {
            if (qFis == qSys) {
              status = 'HIT';
            } else if (qFis < qSys) {
              status = 'MISS';
            } else {
              status = 'OVER';
            }
          }
          if (!['HIT', 'MISS', 'OVER'].contains(status)) {
            status = status.isEmpty ? 'HIT' : status;
          }

          grouped.putIfAbsent(catId, () => {'name': catName, 'items': <Map<String, dynamic>>[]});
          (grouped[catId]!['items'] as List<Map<String, dynamic>>).add({
            'code': code,
            'name': iName >= 0 ? cellStr(iName) : '',
            'qtySistem': qSys,
            'qtyFisik': qFis,
            'status': status,
          });
        }
      }

      if (grouped.isEmpty) {
        setState(() {
          _loading = false;
          _statusMessage = 'Tidak ada baris yang cocok — cek nama kolom di file.';
        });
        return;
      }

      final dbRef = FirebaseDatabase.instance.ref('categories');
      final Map<String, dynamic> updates = {};
      grouped.forEach((catId, data) {
        updates['$catId/name'] = data['name'];
        updates['$catId/items'] = data['items'];
        updates['$catId/status'] = 'available';
        updates['$catId/lockedBy'] = null;
        updates['$catId/lockedAt'] = null;
      });
      await dbRef.update(updates);

      setState(() {
        _loading = false;
        _success = true;
        _statusMessage = 'Berhasil: ${grouped.length} kategori tersimpan ke database.';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _success = false;
        _statusMessage = 'Gagal upload: $e';
      });
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
            padding: const EdgeInsets.all(20),
            decoration:
                BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(28)),
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
                      'Upload data',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Padding(
                  padding: EdgeInsets.only(left: 40, right: 4),
                  child: Text(
                    'Kolom yang dikenali otomatis: Kategori, Item No, Item Name, '
                    'ENDING STOCK WMS, ENDING STOCK NAV, HIT/MISS',
                    style: TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _pickAndUpload,
                    icon: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.upload_file_rounded, size: 18),
                    label: Text(_loading ? 'Memproses...' : 'Pilih file XLSX & upload'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
                if (_statusMessage != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _statusMessage!,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: _success ? AppColors.teal : AppColors.coral,
                    ),
                  ),
                ],
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
