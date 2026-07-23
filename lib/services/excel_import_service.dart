import 'dart:typed_data';

import 'package:excel/excel.dart' as xls;

import '../models/category_assignment.dart';

/// Hasil parsing satu file/teks: daftar kategori baru + item audit per kategori.
class ImportResult {
  final List<CategoryAssignment> categories;
  final Map<String, List<AuditItem>> itemsMap;

  const ImportResult({required this.categories, required this.itemsMap});

  int get totalItemCount =>
      itemsMap.values.fold(0, (sum, items) => sum + items.length);
}

/// Porting logika `processWorkbookData` dari UploadDataScreen.tsx (React)
/// supaya perilaku deteksi kolom & pengelompokan kategori tetap sama persis.
class ExcelImportService {
  ExcelImportService._();

  static String _normHeader(String h) =>
      h.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  static const _itemKeyCandidates = [
    'itemno', 'kodeitem', 'sku', 'itemcode', 'kodebarang', 'code', 'item',
    'noitem', 'itemnumber', 'material',
  ];
  static const _nameKeyCandidates = [
    'itemname', 'namaitem', 'nama', 'namabarang', 'description', 'desc',
    'deskripsi', 'itemdescription',
  ];
  static const _qtyKeyCandidates = [
    'qty', 'quantity', 'stock', 'soh', 'nav', 'wms', 'amount', 'jumlah',
    'ending',
  ];

  static const _categoryCandidates = [
    'kategori', 'category', 'kat', 'dept', 'department', 'location', 'lokasi',
    'whse', 'warehouse', 'zone', 'rak', 'bin', 'group',
  ];
  static const _codeCandidates = [
    'itemno', 'kodeitem', 'kode', 'sku', 'itemcode', 'kodebarang', 'code',
    'noitem', 'material', 'item',
  ];
  static const _nameCandidates = [
    'itemname', 'namaitem', 'nama', 'namabarang', 'description', 'desc',
    'deskripsi', 'itemdescription',
  ];
  static const _qtySysCandidates = [
    'endingstocknav', 'stocknav', 'qtysistem', 'qtysystem', 'stocksistem',
    'qtynav', 'nav', 'systemqty', 'qtyonhand', 'sysstock', 'quantity', 'soh',
  ];
  static const _qtyFisikCandidates = [
    'endingstockwms', 'stockwms', 'qtyfisik', 'qtyreal', 'stockfisik',
    'qtycount', 'qtywms', 'wms', 'wmsstock', 'physicqty', 'realstock',
    'countqty',
  ];
  static const _statusCandidates = ['hitmiss', 'status', 'hasil', 'result'];

  /// Parse bytes file .xlsx/.xls/.csv menjadi [ImportResult].
  static ImportResult parseWorkbookBytes(Uint8List bytes) {
    final excel = xls.Excel.decodeBytes(bytes);
    final grouped = <String, List<AuditItem>>{};

    for (final sheetName in excel.tables.keys) {
      final sheet = excel.tables[sheetName];
      if (sheet == null) continue;
      final rows = sheet.rows
          .map((r) => r.map((c) => c?.value?.toString() ?? '').toList())
          .toList();
      _processRows(sheetName, rows, grouped);
    }

    return _buildResult(grouped);
  }

  /// Parse teks yang di-paste (tab atau koma sebagai pemisah kolom).
  static ImportResult parsePastedText(String text) {
    final lines =
        text.split('\n').map((l) => l.trimRight()).where((l) => l.isNotEmpty).toList();
    final sep = text.contains('\t') ? '\t' : ',';
    final rows = lines.map((l) => l.split(sep)).toList();

    final grouped = <String, List<AuditItem>>{};
    _processRows('Paste', rows, grouped);
    return _buildResult(grouped);
  }

  static void _processRows(
    String sheetName,
    List<List<String>> rows,
    Map<String, List<AuditItem>> grouped,
  ) {
    if (rows.isEmpty) return;

    int headerRowIdx = -1;
    List<String> headerRow = [];

    for (var i = 0; i < rows.length && i < 30; i++) {
      final cells = rows[i];
      final normalized = cells.map(_normHeader).toList();
      final hasItemKey =
          normalized.any((c) => _itemKeyCandidates.any((k) => c.contains(k)));
      final hasNameKey =
          normalized.any((c) => _nameKeyCandidates.any((k) => c.contains(k)));
      final hasQtyKey =
          normalized.any((c) => _qtyKeyCandidates.any((k) => c.contains(k)));

      if ((hasItemKey && hasNameKey) ||
          (hasItemKey && hasQtyKey) ||
          (hasNameKey && hasQtyKey)) {
        headerRowIdx = i;
        headerRow = cells;
        break;
      }
    }

    if (headerRowIdx == -1) {
      for (var i = 0; i < rows.length && i < 15; i++) {
        if (rows[i].length >= 3) {
          headerRowIdx = i;
          headerRow = rows[i];
          break;
        }
      }
    }

    if (headerRowIdx == -1 && rows.isNotEmpty) {
      headerRowIdx = 0;
      headerRow = rows[0];
    }

    int idxOf(List<String> candidates) {
      for (var c = 0; c < headerRow.length; c++) {
        final norm = _normHeader(headerRow[c]);
        if (candidates.any((cand) => norm.contains(cand))) return c;
      }
      return -1;
    }

    final iCategory = idxOf(_categoryCandidates);
    final iCode = idxOf(_codeCandidates);
    final iName = idxOf(_nameCandidates);
    final iQtySys = idxOf(_qtySysCandidates);
    final iQtyFisik = idxOf(_qtyFisikCandidates);
    final iStatus = idxOf(_statusCandidates);

    String cellStr(List<String> row, int idx) =>
        (idx >= 0 && idx < row.length) ? row[idx].trim() : '';

    num cellNum(List<String> row, int idx) {
      if (idx < 0 || idx >= row.length) return 0;
      final clean = row[idx].replaceAll(',', '').trim();
      return num.tryParse(clean) ?? 0;
    }

    for (var r = headerRowIdx + 1; r < rows.length; r++) {
      final row = rows[r];
      if (row.isEmpty) continue;

      final code = (iCode >= 0 ? cellStr(row, iCode) : '').isNotEmpty
          ? cellStr(row, iCode)
          : cellStr(row, 0);
      if (code.isEmpty) continue;

      final codeLower = code.toLowerCase();
      if (codeLower.contains('total') ||
          codeLower.contains('report') ||
          codeLower.contains('page') ||
          codeLower.startsWith('location:') ||
          codeLower.startsWith('date:') ||
          codeLower == 'item' ||
          codeLower == 'item no' ||
          codeLower == 'kode') {
        continue;
      }

      final catRaw = iCategory >= 0 ? cellStr(row, iCategory) : '';
      final catName = catRaw.isNotEmpty ? catRaw : sheetName;

      final nameRaw = iName >= 0 ? cellStr(row, iName) : '';
      final name = nameRaw.isNotEmpty
          ? nameRaw
          : (cellStr(row, 1).isNotEmpty ? cellStr(row, 1) : 'Item $code');

      final qSys = iQtySys >= 0 ? cellNum(row, iQtySys) : cellNum(row, 2);
      final qFis = iQtyFisik >= 0 ? cellNum(row, iQtyFisik) : cellNum(row, 3);

      var statusStr =
          iStatus >= 0 ? cellStr(row, iStatus).toUpperCase() : '';
      if (!['HIT', 'MISS', 'OVER'].contains(statusStr)) {
        if (qFis == qSys) {
          statusStr = 'HIT';
        } else if (qFis < qSys) {
          statusStr = 'MISS';
        } else {
          statusStr = 'OVER';
        }
      }

      grouped.putIfAbsent(catName, () => []);
      grouped[catName]!.add(AuditItem(
        id: 'item-$r-${code.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}',
        name: name,
        codeWms: code,
        codeNav: 'NAV-$code',
        wmsStock: qFis,
        navStock: qSys,
        status: statusStr,
      ));
    }
  }

  static ImportResult _buildResult(Map<String, List<AuditItem>> grouped) {
    final categoryNames =
        grouped.keys.where((name) => !isInvalidCategoryName(name)).toList();

    final now = DateTime.now().millisecondsSinceEpoch;
    final categories = <CategoryAssignment>[];
    final itemsMap = <String, List<AuditItem>>{};

    for (var i = 0; i < categoryNames.length; i++) {
      final name = categoryNames[i];
      categories.add(CategoryAssignment(
        id: 'cat-up-$now-$i',
        categoryName: name,
        assignedUsername: null,
        status: 'available',
        itemCount: grouped[name]!.length,
      ));
      itemsMap[name] = grouped[name]!;
    }

    return ImportResult(categories: categories, itemsMap: itemsMap);
  }
}
