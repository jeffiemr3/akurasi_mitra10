import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/category_assignment.dart';
import '../services/excel_import_service.dart';
import '../services/realtime_db_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

enum _UploadTab { excel, paste, manual }

/// Porting dari src/screens/UploadDataScreen.tsx — input data stok WMS vs NAV
/// lewat file Excel, copy-paste teks, atau form manual satu-per-satu.
class UploadDataScreen extends StatefulWidget {
  const UploadDataScreen({super.key});

  @override
  State<UploadDataScreen> createState() => _UploadDataScreenState();
}

class _UploadDataScreenState extends State<UploadDataScreen> {
  final _db = RealtimeDbService.instance;
  _UploadTab _tab = _UploadTab.excel;
  bool _loading = false;
  String? _statusMessage;
  bool _isSuccess = false;
  ImportResult? _lastResult;

  final _pasteController = TextEditingController();

  final _manualCatCtrl = TextEditingController(text: 'PLUMBING');
  final _manualCodeWmsCtrl = TextEditingController();
  final _manualCodeNavCtrl = TextEditingController();
  final _manualNameCtrl = TextEditingController();
  final _manualWmsCtrl = TextEditingController(text: '0');
  final _manualNavCtrl = TextEditingController(text: '0');

  @override
  void dispose() {
    _pasteController.dispose();
    _manualCatCtrl.dispose();
    _manualCodeWmsCtrl.dispose();
    _manualCodeNavCtrl.dispose();
    _manualNameCtrl.dispose();
    _manualWmsCtrl.dispose();
    _manualNavCtrl.dispose();
    super.dispose();
  }

  Future<void> _persistResult(ImportResult result) async {
    // Simpan kategori baru (skip yang namanya sudah ada).
    final existing = await _db.watchCategories().first;
    final existingNames = existing.map((c) => c.categoryName).toSet();
    final newCats =
        result.categories.where((c) => !existingNames.contains(c.categoryName));
    if (newCats.isNotEmpty) {
      await _db.saveCategories(newCats.toList());
    }

    for (final entry in result.itemsMap.entries) {
      await _db.saveItemsForCategory(entry.key, entry.value);
    }

    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final timestamp =
        '${two(now.day)}/${two(now.month)}/${now.year} ${two(now.hour)}:${two(now.minute)} WIB';
    await _db.saveLastUploadAt(timestamp);
  }

  Future<void> _handlePickExcel() async {
    setState(() {
      _loading = true;
      _statusMessage = 'Membaca dan memasukkan data ke database...';
      _isSuccess = false;
    });

    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) {
        setState(() {
          _loading = false;
          _statusMessage = null;
        });
        return;
      }

      final bytes = picked.files.first.bytes;
      if (bytes == null) {
        throw Exception('Gagal membaca isi file.');
      }

      final result = ExcelImportService.parseWorkbookBytes(bytes);
      await _finishImport(result);
    } catch (e) {
      setState(() {
        _loading = false;
        _isSuccess = false;
        _statusMessage = 'Gagal memproses file Excel: $e';
      });
    }
  }

  Future<void> _handleProcessPastedText() async {
    if (_pasteController.text.trim().isEmpty) {
      setState(() {
        _statusMessage = 'Silakan tempel (paste) data teks terlebih dahulu.';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _statusMessage = null;
    });

    try {
      final result = ExcelImportService.parsePastedText(_pasteController.text);
      await _finishImport(result);
    } catch (e) {
      setState(() {
        _loading = false;
        _isSuccess = false;
        _statusMessage = 'Gagal memproses teks: $e';
      });
    }
  }

  Future<void> _finishImport(ImportResult result) async {
    if (result.categories.isEmpty) {
      setState(() {
        _loading = false;
        _isSuccess = false;
        _statusMessage =
            'Tidak ada data yang dapat diproses. Pastikan file mengandung kolom item dan stok.';
      });
      return;
    }

    await _persistResult(result);

    setState(() {
      _loading = false;
      _isSuccess = true;
      _lastResult = result;
      _statusMessage =
          'Berhasil menyimpan ke Database: ${result.categories.length} Kategori, ${result.totalItemCount} Item Stok.';
    });
  }

  Future<void> _handleManualAdd() async {
    if (_manualNameCtrl.text.trim().isEmpty ||
        _manualCodeWmsCtrl.text.trim().isEmpty) {
      setState(() {
        _statusMessage = 'Nama item dan Kode WMS wajib diisi.';
        _isSuccess = false;
      });
      return;
    }

    final wms = num.tryParse(_manualWmsCtrl.text.trim()) ?? 0;
    final nav = num.tryParse(_manualNavCtrl.text.trim()) ?? 0;
    String status = 'HIT';
    if (wms < nav) {
      status = 'MISS';
    } else if (wms > nav) {
      status = 'OVER';
    }

    final catName =
        _manualCatCtrl.text.trim().isEmpty ? 'Umum' : _manualCatCtrl.text.trim();

    final item = AuditItem(
      id: 'item-${DateTime.now().millisecondsSinceEpoch}',
      name: _manualNameCtrl.text.trim(),
      codeWms: _manualCodeWmsCtrl.text.trim(),
      codeNav: _manualCodeNavCtrl.text.trim().isEmpty
          ? 'NAV-${_manualCodeWmsCtrl.text.trim()}'
          : _manualCodeNavCtrl.text.trim(),
      wmsStock: wms,
      navStock: nav,
      status: status,
    );

    final existing = await _db.watchCategories().first;
    final alreadyExists = existing.any((c) => c.categoryName == catName);
    if (!alreadyExists) {
      final newCat = CategoryAssignment(
        id: 'cat-${DateTime.now().millisecondsSinceEpoch}',
        categoryName: catName,
        assignedUsername: null,
        status: 'available',
        itemCount: 1,
      );
      await _db.upsertCategory(newCat);
    }
    await _db.saveItemsForCategory(catName, [item]);

    setState(() {
      _isSuccess = true;
      _statusMessage =
          'Item "${item.name}" berhasil ditambahkan ke database kategori $catName!';
      _manualNameCtrl.clear();
      _manualCodeWmsCtrl.clear();
      _manualCodeNavCtrl.clear();
    });
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
                  const ScreenLabel('Input & Masukkan Data Stok'),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  child: AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Konfigurasi & Input Data',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Masukkan data stok ke database Mitra10 melalui File Excel, Copy-Paste Teks, atau Form Manual.',
                          style:
                              TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
                        ),
                        const SizedBox(height: 16),
                        _buildTabSwitcher(),
                        const SizedBox(height: 18),
                        if (_tab == _UploadTab.excel) _buildExcelTab(),
                        if (_tab == _UploadTab.paste) _buildPasteTab(),
                        if (_tab == _UploadTab.manual) _buildManualTab(),
                        if (_statusMessage != null) ...[
                          const SizedBox(height: 14),
                          StatusBanner(
                              message: _statusMessage!, success: _isSuccess),
                        ],
                        if (_lastResult != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF9F5),
                              border: Border.all(color: AppColors.line),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kategori Terimpor (${_lastResult!.categories.length}):',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppColors.ink),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: _lastResult!.categories
                                      .map((c) => Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.avatarNavyBg,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              c.categoryName,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.navy),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    Widget tabButton(_UploadTab value, IconData icon, String label) {
      final selected = _tab == value;
      return Expanded(
        child: InkWell(
          onTap: () => setState(() => _tab = value),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: selected
                  ? const [
                      BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 4,
                          offset: Offset(0, 1))
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 14,
                    color: selected ? AppColors.navy : AppColors.inkSoft),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: selected ? AppColors.navy : AppColors.inkSoft,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          tabButton(_UploadTab.excel, Icons.table_chart_outlined, 'File Excel'),
          tabButton(_UploadTab.paste, Icons.article_outlined, 'Copy-Paste'),
          tabButton(_UploadTab.manual, Icons.add_circle_outline, 'Manual'),
        ],
      ),
    );
  }

  Widget _buildExcelTab() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        border: Border.all(color: AppColors.line, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.table_chart_outlined, size: 44, color: AppColors.navy),
          const SizedBox(height: 8),
          const Text(
            'Pilih file Microsoft Excel (.xlsx, .xls, .csv)',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.ink),
          ),
          const SizedBox(height: 4),
          const Text(
            'File otomatis dibaca dan dimasukkan ke dalam database stok Mitra10.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 220,
            child: PrimaryButton(
              label: _loading ? 'Memproses File...' : 'Upload File Excel',
              loading: _loading,
              icon: Icons.upload,
              onPressed: _handlePickExcel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasteTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tempel (Paste) data dari Excel / Google Sheets / WhatsApp:',
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _pasteController,
          maxLines: 6,
          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          decoration: InputDecoration(
            hintText:
                'Contoh format:\nKategori\tKode Item\tNama Barang\tNAV\tWMS\nSanitary\t1002341\tKran Air Onda 1/2\t10\t10',
            filled: true,
            fillColor: AppColors.fieldFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.line),
            ),
          ),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Proses & Masukkan ke Database',
          loading: _loading,
          icon: Icons.check_circle_outline,
          onPressed: _handleProcessPastedText,
        ),
      ],
    );
  }

  Widget _buildManualTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AppTextField(
                  controller: _manualCatCtrl,
                  label: 'Kategori',
                  hint: 'Sanitary & Plumbing'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppTextField(
                  controller: _manualCodeWmsCtrl,
                  label: 'Kode Item WMS *',
                  hint: '1004523'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                  controller: _manualCodeNavCtrl,
                  label: 'Kode NAV',
                  hint: 'NAV-1004523'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppTextField(
                  controller: _manualNameCtrl,
                  label: 'Nama Item Barang *',
                  hint: 'Wastafel Toto White'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _manualWmsCtrl,
                label: 'Stok WMS (Fisik)',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppTextField(
                controller: _manualNavCtrl,
                label: 'Stok NAV (Sistem)',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        PrimaryButton(
          label: 'Simpan Single Item ke Database',
          icon: Icons.add_circle_outline,
          onPressed: _handleManualAdd,
        ),
      ],
    );
  }
}
