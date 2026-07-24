import React, { useState } from 'react';
import {
  ArrowLeft,
  Upload,
  FileSpreadsheet,
  CheckCircle2,
  AlertCircle,
  Loader2,
  FileText,
  PlusCircle,
  Layers,
  X,
  Archive,
} from 'lucide-react';
import * as XLSX from 'xlsx';
import { CategoryAssignment, AuditItem } from '../types';
import {
  detectReportType,
  parseWmsVsNav,
  parseWarehouseLocation,
  parseQtyAndValue,
  buildCatalogFromReports,
  SystemReportType,
  CatalogBuildSummary,
} from '../services/reportParser';
import { CatalogSaveSummary } from '../services/database';

interface UploadDataScreenProps {
  onBack: () => void;
  onUploadSuccess: (
    newCategories: CategoryAssignment[],
    newItemsMap: Record<string, AuditItem[]>
  ) => void;
  onUploadSystemReports: (
    itemsMap: Record<string, AuditItem[]>
  ) => Promise<CatalogSaveSummary>;
}

const SYSTEM_REPORT_LABELS: Record<SystemReportType, string> = {
  wms_nav: 'Report Stock WMS vs NAV',
  warehouse_location: 'Report Stock Warehouse By Location',
  qty_value: 'Stock Qty and Value',
  unknown: 'Tidak dikenali',
};

export const UploadDataScreen: React.FC<UploadDataScreenProps> = ({
  onBack,
  onUploadSuccess,
  onUploadSystemReports,
}) => {
  const [activeTab, setActiveTab] = useState<'system' | 'excel' | 'paste' | 'manual'>('system');
  const [loading, setLoading] = useState(false);
  const [statusMessage, setStatusMessage] = useState<string | null>(null);
  const [isSuccess, setIsSuccess] = useState(false);
  const [previewSummary, setPreviewSummary] = useState<{
    categoryCount: number;
    itemCount: number;
    categoryNames: string[];
  } | null>(null);

  // Paste Text state
  const [pastedText, setPastedText] = useState('');

  // Manual Item state
  const [manualCat, setManualCat] = useState('Sanitary & Plumbing');
  const [manualCodeWms, setManualCodeWms] = useState('');
  const [manualCodeNav, setManualCodeNav] = useState('');
  const [manualName, setManualName] = useState('');
  const [manualStockWms, setManualStockWms] = useState<number>(0);
  const [manualStockNav, setManualStockNav] = useState<number>(0);

  // Laporan Sistem (3 file) state
  const [systemFiles, setSystemFiles] = useState<Partial<Record<SystemReportType, File>>>({});
  const [systemProcessing, setSystemProcessing] = useState(false);
  const [systemError, setSystemError] = useState<string | null>(null);
  const [systemResult, setSystemResult] = useState<{
    summary: CatalogBuildSummary;
    save: CatalogSaveSummary;
  } | null>(null);

  const normHeader = (h: any) =>
    String(h || '').toLowerCase().replace(/[^a-z0-9]/g, '');

  const processWorkbookData = (workbook: XLSX.WorkBook) => {
    const grouped: Record<string, { name: string; items: AuditItem[] }> = {};

    workbook.SheetNames.forEach((sheetName) => {
      const sheet = workbook.Sheets[sheetName];
      const rows: any[][] = XLSX.utils.sheet_to_json(sheet, { header: 1 });

      let headerRowIdx = -1;
      let headerRow: string[] = [];

      for (let i = 0; i < rows.length && i < 30; i++) {
        const cells = (rows[i] || []).map((c) => String(c || ''));
        const normalized = cells.map(normHeader);
        const hasItemNo = normalized.some((c) =>
          ['itemno', 'kodeitem', 'sku', 'itemcode', 'kodebarang', 'code'].includes(c)
        );
        const hasName = normalized.some((c) =>
          ['itemname', 'namaitem', 'nama', 'namabarang', 'description', 'desc'].includes(c)
        );

        if (hasItemNo || hasName || cells.length >= 2) {
          headerRowIdx = i;
          headerRow = cells;
          break;
        }
      }

      if (headerRowIdx === -1 && rows.length > 0) {
        headerRowIdx = 0;
        headerRow = (rows[0] || []).map((c) => String(c || ''));
      }

      const idxOf = (candidates: string[]) => {
        for (let c = 0; c < headerRow.length; c++) {
          if (candidates.includes(normHeader(headerRow[c]))) return c;
        }
        return -1;
      };

      const iCategory = idxOf(['kategori', 'category', 'kat']);
      const iCode = idxOf(['itemno', 'kodeitem', 'kode', 'sku', 'itemcode', 'kodebarang', 'code']);
      const iName = idxOf(['itemname', 'namaitem', 'nama', 'namabarang', 'description', 'desc']);
      const iQtySys = idxOf([
        'endingstocknav',
        'stocknav',
        'qtysistem',
        'qtysystem',
        'stocksistem',
        'qtynav',
        'nav',
      ]);
      const iQtyFisik = idxOf([
        'endingstockwms',
        'stockwms',
        'qtyfisik',
        'qtyreal',
        'stockfisik',
        'qtycount',
        'qtywms',
        'wms',
      ]);
      const iStatus = idxOf(['hitmiss', 'status', 'hasil', 'result']);

      for (let r = headerRowIdx + 1; r < rows.length; r++) {
        const row = rows[r] || [];
        if (row.length === 0) continue;

        const cellStr = (idx: number) => (idx >= 0 && idx < row.length ? String(row[idx] || '').trim() : '');
        const cellNum = (idx: number) => {
          if (idx < 0 || idx >= row.length) return 0;
          const v = Number(row[idx]);
          return isNaN(v) ? 0 : v;
        };

        const code = (iCode >= 0 ? cellStr(iCode) : '') || cellStr(0);
        if (!code) continue;

        const catRaw = iCategory >= 0 ? cellStr(iCategory) : '';
        const catName = catRaw || sheetName || 'TANPA KATEGORI';

        const name = (iName >= 0 ? cellStr(iName) : '') || cellStr(1) || `Item ${code}`;

        const qSys = iQtySys >= 0 ? cellNum(iQtySys) : cellNum(2);
        const qFis = iQtyFisik >= 0 ? cellNum(iQtyFisik) : cellNum(3);

        let statusStr = iStatus >= 0 ? cellStr(iStatus).toUpperCase() : '';
        if (!['HIT', 'MISS', 'OVER'].includes(statusStr)) {
          if (qFis === qSys) statusStr = 'HIT';
          else if (qFis < qSys) statusStr = 'MISS';
          else statusStr = 'OVER';
        }

        if (!grouped[catName]) {
          grouped[catName] = { name: catName, items: [] };
        }

        grouped[catName].items.push({
          id: `item-${Date.now()}-${Math.random().toString(36).substring(2, 6)}`,
          name,
          codeWms: code,
          codeNav: `NAV-${code}`,
          wmsStock: qFis,
          navStock: qSys,
          status: statusStr as 'HIT' | 'MISS' | 'OVER',
        });
      }
    });

    const categoryNames = Object.keys(grouped);
    if (categoryNames.length === 0) {
      setLoading(false);
      setStatusMessage('Tidak ada data yang dapat diproses. Pastikan format mengandung kolom data item.');
      setIsSuccess(false);
      return;
    }

    const totalItemCount = Object.values(grouped).reduce((acc, c) => acc + c.items.length, 0);

    const newCats: CategoryAssignment[] = categoryNames.map((catName, idx) => ({
      id: `cat-up-${Date.now()}-${idx}`,
      categoryName: catName,
      assignedUsername: null,
      status: 'available',
      itemCount: grouped[catName].items.length,
    }));

    const newItemsMap: Record<string, AuditItem[]> = {};
    categoryNames.forEach((catName) => {
      newItemsMap[catName] = grouped[catName].items;
    });

    onUploadSuccess(newCats, newItemsMap);

    setLoading(false);
    setIsSuccess(true);
    setStatusMessage(`Berhasil menyimpan ke Database: ${categoryNames.length} Kategori, ${totalItemCount} Item Stok.`);
    setPreviewSummary({
      categoryCount: categoryNames.length,
      itemCount: totalItemCount,
      categoryNames,
    });
  };

  const handleFileUpload = (file: File) => {
    setLoading(true);
    setStatusMessage('Membaca dan memasukkan data ke database...');
    setIsSuccess(false);

    const reader = new FileReader();
    reader.onload = (e) => {
      try {
        const data = new Uint8Array(e.target?.result as ArrayBuffer);
        const workbook = XLSX.read(data, { type: 'array' });
        processWorkbookData(workbook);
      } catch (err: any) {
        setLoading(false);
        setIsSuccess(false);
        setStatusMessage(`Gagal membaca file: ${err.message || 'Format tidak valid'}`);
      }
    };

    reader.readAsArrayBuffer(file);
  };

  const handleProcessPastedText = () => {
    if (!pastedText.trim()) {
      setStatusMessage('Silakan tempel (paste) data teks terlebih dahulu.');
      setIsSuccess(false);
      return;
    }

    setLoading(true);
    try {
      // Create virtual workbook from CSV or Tab-delimited text
      const workbook = XLSX.read(pastedText, { type: 'string' });
      processWorkbookData(workbook);
    } catch (err: any) {
      setLoading(false);
      setIsSuccess(false);
      setStatusMessage(`Gagal memproses teks: ${err.message || 'Format teks tidak dapat dibaca'}`);
    }
  };

  const handleManualAdd = (e: React.FormEvent) => {
    e.preventDefault();
    if (!manualName.trim() || !manualCodeWms.trim()) {
      setStatusMessage('Nama item dan Kode WMS wajib diisi.');
      setIsSuccess(false);
      return;
    }

    let statusStr: 'HIT' | 'MISS' | 'OVER' = 'HIT';
    if (manualStockWms < manualStockNav) statusStr = 'MISS';
    else if (manualStockWms > manualStockNav) statusStr = 'OVER';

    const catName = manualCat.trim() || 'Umum';
    const newItem: AuditItem = {
      id: `item-${Date.now()}`,
      name: manualName.trim(),
      codeWms: manualCodeWms.trim(),
      codeNav: manualCodeNav.trim() || `NAV-${manualCodeWms.trim()}`,
      wmsStock: Number(manualStockWms) || 0,
      navStock: Number(manualStockNav) || 0,
      status: statusStr,
    };

    const newCat: CategoryAssignment = {
      id: `cat-${Date.now()}`,
      categoryName: catName,
      assignedUsername: null,
      status: 'available',
      itemCount: 1,
    };

    onUploadSuccess([newCat], { [catName]: [newItem] });

    setIsSuccess(true);
    setStatusMessage(`Item "${manualName}" berhasil ditambahkan ke database kategori ${catName}!`);
    setManualName('');
    setManualCodeWms('');
    setManualCodeNav('');
  };

  const handleSystemFilesSelected = async (fileList: FileList | null) => {
    if (!fileList || fileList.length === 0) return;
    setSystemError(null);

    const updated = { ...systemFiles };
    for (const file of Array.from(fileList)) {
      try {
        const buf = await file.arrayBuffer();
        const wb = XLSX.read(buf, { type: 'array' });
        const type = detectReportType(wb);
        if (type === 'unknown') {
          setSystemError(
            `File "${file.name}" tidak dikenali — pastikan ini salah satu dari 3 laporan sistem yang didukung.`
          );
          continue;
        }
        updated[type] = file;
      } catch (err: any) {
        setSystemError(`Gagal membaca "${file.name}": ${err.message || 'format tidak valid'}`);
      }
    }
    setSystemFiles(updated);
  };

  const handleRemoveSystemFile = (type: SystemReportType) => {
    setSystemFiles((prev) => {
      const next = { ...prev };
      delete next[type];
      return next;
    });
    setSystemResult(null);
  };

  const handleProcessSystemReports = async () => {
    if (!systemFiles.wms_nav) {
      setSystemError(
        'File "Report Stock WMS vs NAV" wajib diupload — ini sumber kategori & status HIT/MISS/OVER.'
      );
      return;
    }

    setSystemProcessing(true);
    setSystemError(null);
    setSystemResult(null);

    try {
      const wmsWb = XLSX.read(await systemFiles.wms_nav.arrayBuffer(), { type: 'array' });
      const wmsMap = parseWmsVsNav(wmsWb);

      const locationMap = systemFiles.warehouse_location
        ? parseWarehouseLocation(
            XLSX.read(await systemFiles.warehouse_location.arrayBuffer(), { type: 'array' })
          )
        : new Map<string, string>();

      const priceMap = systemFiles.qty_value
        ? parseQtyAndValue(XLSX.read(await systemFiles.qty_value.arrayBuffer(), { type: 'array' }))
        : new Map<string, number>();

      const { catalog, summary } = buildCatalogFromReports(wmsMap, locationMap, priceMap);

      if (summary.totalItems === 0) {
        setSystemError('Tidak ada baris data valid yang ditemukan di file WMS vs NAV.');
        setSystemProcessing(false);
        return;
      }

      const save = await onUploadSystemReports(catalog);
      setSystemResult({ summary, save });
    } catch (err: any) {
      setSystemError(`Gagal memproses file: ${err.message || 'terjadi kesalahan tak terduga'}`);
    } finally {
      setSystemProcessing(false);
    }
  };

  const formatBytes = (n: number) => {
    if (n < 1024) return `${n} B`;
    if (n < 1024 * 1024) return `${(n / 1024).toFixed(1)} KB`;
    return `${(n / (1024 * 1024)).toFixed(2)} MB`;
  };

  return (
    <div className="min-h-screen bg-[#DCE7F7] flex flex-col p-4 sm:p-6">
      <div className="w-full max-w-[640px] mx-auto flex flex-col flex-1">
        {/* Header */}
        <div className="flex items-center gap-3 mb-3">
          <button
            id="btn-upload-back"
            onClick={onBack}
            className="w-8 h-8 rounded-full bg-white border border-[#DDE4F0] flex items-center justify-center text-[#172554] hover:bg-gray-50"
          >
            <ArrowLeft size={16} />
          </button>
          <span className="text-[12px] font-bold tracking-wider text-[#5B688A] uppercase">
            INPUT & MASUKKAN DATA STOK
          </span>
        </div>

        {/* Content Card */}
        <div className="bg-white rounded-[28px] p-5 sm:p-7 flex-1 flex flex-col shadow-sm">
          <div>
            <h1 className="text-[20px] font-bold text-[#172554]">Konfigurasi & Input Data</h1>
            <p className="text-[11.5px] text-[#5B688A] mt-1 leading-relaxed">
              Masukkan data stok ke database Mitra10 melalui File Excel, Copy-Paste Teks, atau Form Manual.
            </p>
          </div>

          {/* Mode Switcher Tabs */}
          <div className="mt-4 grid grid-cols-4 gap-1.5 p-1 bg-[#F4F7FC] border border-[#DDE4F0] rounded-xl text-[11px] font-bold text-[#172554]">
            <button
              onClick={() => setActiveTab('system')}
              className={`py-2 px-1.5 rounded-lg transition-all flex items-center justify-center gap-1 ${
                activeTab === 'system' ? 'bg-white shadow-xs text-[#16225C]' : 'text-[#5B688A] hover:text-[#172554]'
              }`}
            >
              <Layers size={13} /> Laporan Sistem
            </button>
            <button
              onClick={() => setActiveTab('excel')}
              className={`py-2 px-1.5 rounded-lg transition-all flex items-center justify-center gap-1 ${
                activeTab === 'excel' ? 'bg-white shadow-xs text-[#16225C]' : 'text-[#5B688A] hover:text-[#172554]'
              }`}
            >
              <FileSpreadsheet size={13} /> File Lain
            </button>
            <button
              onClick={() => setActiveTab('paste')}
              className={`py-2 px-1.5 rounded-lg transition-all flex items-center justify-center gap-1 ${
                activeTab === 'paste' ? 'bg-white shadow-xs text-[#16225C]' : 'text-[#5B688A] hover:text-[#172554]'
              }`}
            >
              <FileText size={13} /> Copy-Paste
            </button>
            <button
              onClick={() => setActiveTab('manual')}
              className={`py-2 px-1.5 rounded-lg transition-all flex items-center justify-center gap-1 ${
                activeTab === 'manual' ? 'bg-white shadow-xs text-[#16225C]' : 'text-[#5B688A] hover:text-[#172554]'
              }`}
            >
              <PlusCircle size={13} /> Manual
            </button>
          </div>

          {/* TAB 0: Laporan Sistem (3 File Khusus) */}
          {activeTab === 'system' && (
            <div className="mt-5 flex-1 flex flex-col space-y-3">
              <div className="p-3 bg-[#EBEEFA] border border-[#DDE4F0] rounded-xl text-[11px] text-[#16225C] leading-relaxed">
                Upload salah satu, dua, atau ketiga file laporan sistem sekaligus (bisa dipilih
                bersamaan). Jenis file dideteksi otomatis dari isi kolomnya — nama file bebas.
                <br />
                <b>Report Stock WMS vs NAV</b> wajib ada (sumber kategori & status HIT/MISS/OVER).
                Dua file lain opsional untuk melengkapi lokasi & harga satuan.
              </div>

              <label className="cursor-pointer border-2 border-dashed border-[#DDE4F0] hover:border-[#16225C] rounded-2xl p-5 bg-[#F4F7FC] text-center transition-colors flex flex-col items-center">
                <Upload size={28} className="text-[#16225C] mb-1.5" />
                <span className="text-[13px] font-bold text-[#172554]">
                  Pilih 1–3 file Excel (.xlsx)
                </span>
                <span className="text-[11px] text-[#5B688A] mt-0.5">
                  Bisa pilih beberapa file sekaligus (Ctrl/Cmd+klik)
                </span>
                <input
                  type="file"
                  accept=".xlsx,.xls"
                  multiple
                  onChange={(e) => {
                    handleSystemFilesSelected(e.target.files);
                    e.target.value = '';
                  }}
                  disabled={systemProcessing}
                  className="hidden"
                />
              </label>

              {/* Slot status per jenis laporan */}
              <div className="space-y-2">
                {(['wms_nav', 'warehouse_location', 'qty_value'] as SystemReportType[]).map((type) => {
                  const file = systemFiles[type];
                  return (
                    <div
                      key={type}
                      className={`p-3 rounded-xl border flex items-center justify-between ${
                        file ? 'bg-[#E1F5EE] border-[#0F6E56]/20' : 'bg-[#FAF9F5] border-[#DDE4F0]'
                      }`}
                    >
                      <div className="flex items-center gap-2.5 min-w-0">
                        {file ? (
                          <CheckCircle2 size={16} className="text-[#0F6E56] shrink-0" />
                        ) : (
                          <div className="w-4 h-4 rounded-full border-2 border-[#DDE4F0] shrink-0" />
                        )}
                        <div className="min-w-0">
                          <span className="text-[12px] font-semibold text-[#172554] block">
                            {SYSTEM_REPORT_LABELS[type]}
                            {type === 'wms_nav' && (
                              <span className="text-[#B3131A]"> *</span>
                            )}
                          </span>
                          <span className="text-[10.5px] text-[#5B688A] truncate block">
                            {file ? file.name : 'Belum dipilih'}
                          </span>
                        </div>
                      </div>
                      {file && (
                        <button
                          onClick={() => handleRemoveSystemFile(type)}
                          className="w-6 h-6 rounded-full bg-white border border-[#DDE4F0] flex items-center justify-center text-[#5B688A] hover:text-[#B3131A] shrink-0"
                        >
                          <X size={12} />
                        </button>
                      )}
                    </div>
                  );
                })}
              </div>

              <button
                onClick={handleProcessSystemReports}
                disabled={systemProcessing || !systemFiles.wms_nav}
                className="w-full bg-[#16225C] hover:bg-[#1F2E75] disabled:opacity-50 text-white py-3.5 rounded-xl text-[13.5px] font-semibold flex items-center justify-center gap-2 transition-colors shadow-xs"
              >
                {systemProcessing ? (
                  <Loader2 className="animate-spin" size={16} />
                ) : (
                  <Archive size={16} />
                )}
                {systemProcessing ? 'Memproses & Menyimpan...' : 'Gabungkan & Simpan ke Firebase'}
              </button>

              {systemError && (
                <div className="p-3 bg-[#FBE6E7] border border-[#B3131A]/20 text-[#B3131A] rounded-xl text-[12px] font-medium flex items-start gap-2">
                  <AlertCircle size={16} className="shrink-0 mt-0.5" /> <span>{systemError}</span>
                </div>
              )}

              {systemResult && (
                <div className="p-3.5 bg-[#E1F5EE] border border-[#0F6E56]/20 text-[#0F6E56] rounded-xl text-[12px] space-y-1.5">
                  <div className="flex items-center gap-2 font-bold">
                    <CheckCircle2 size={16} /> Berhasil disimpan ke Firebase
                  </div>
                  <div>
                    {systemResult.summary.totalItems.toLocaleString('id-ID')} item ·{' '}
                    {systemResult.summary.totalCategories} kategori
                  </div>
                  <div>
                    Lokasi terisi: {systemResult.summary.itemsWithLocation.toLocaleString('id-ID')} item
                    · Harga satuan terisi: {systemResult.summary.itemsWithPrice.toLocaleString('id-ID')} item
                  </div>
                  <div className="pt-1 border-t border-[#0F6E56]/20">
                    Ukuran data: {formatBytes(systemResult.save.totalOriginalSize)} →{' '}
                    <b>{formatBytes(systemResult.save.totalStoredSize)}</b> tersimpan
                    {systemResult.save.compressedCategories > 0 && (
                      <>
                        {' '}
                        ({systemResult.save.compressedCategories}/{systemResult.save.totalCategories}{' '}
                        kategori dikompres otomatis)
                      </>
                    )}
                  </div>
                </div>
              )}
            </div>
          )}

          {/* TAB: File Excel format lain (generik, heuristik kolom) */}
          {activeTab === 'excel' && (
            <div className="mt-5 flex-1 flex flex-col items-center justify-center border-2 border-dashed border-[#DDE4F0] hover:border-[#16225C] rounded-2xl p-6 bg-[#F4F7FC] text-center transition-colors">
              <FileSpreadsheet size={44} className="text-[#16225C] mb-2" />
              <span className="text-[13.5px] font-bold text-[#172554]">
                Pilih file Excel format lain (.xlsx, .xls)
              </span>
              <p className="text-[11.5px] text-[#5B688A] mt-1 max-w-[340px]">
                Untuk file selain 3 laporan sistem standar. Kolom dideteksi otomatis
                berdasarkan nama header (Kategori, Item No, WMS, NAV, dst).
              </p>

              <label className="mt-4 cursor-pointer bg-[#16225C] hover:bg-[#1F2E75] text-white px-5 py-2.5 rounded-xl text-[13px] font-semibold transition-colors shadow-xs inline-flex items-center gap-2">
                {loading ? <Loader2 className="animate-spin" size={16} /> : <Upload size={16} />}
                {loading ? 'Memproses File...' : 'Upload File Excel'}
                <input
                  type="file"
                  accept=".xlsx, .xls, .csv"
                  onChange={(e) => e.target.files?.[0] && handleFileUpload(e.target.files[0])}
                  disabled={loading}
                  className="hidden"
                />
              </label>
            </div>
          )}

          {/* TAB 2: Copy-Paste Teks */}
          {activeTab === 'paste' && (
            <div className="mt-5 flex-1 flex flex-col space-y-3">
              <label className="block text-[12px] font-semibold text-[#172554]">
                Tempel (Paste) data dari Excel / Google Sheets / WhatsApp:
              </label>
              <textarea
                rows={6}
                value={pastedText}
                onChange={(e) => setPastedText(e.target.value)}
                placeholder={`Contoh format:\nKategori\tKode Item\tNama Barang\tNAV\tWMS\nSanitary\t1002341\tKran Air Onda 1/2\t10\t10\nFlooring\t1008812\tKeramik Milan 40x40\t25\t23`}
                className="w-full p-3 bg-[#F4F7FC] border border-[#DDE4F0] rounded-xl text-[12px] font-mono text-[#172554] focus:outline-none focus:border-[#16225C]"
              />
              <button
                onClick={handleProcessPastedText}
                disabled={loading}
                className="w-full bg-[#16225C] hover:bg-[#1F2E75] text-white py-3 rounded-xl text-[13px] font-semibold flex items-center justify-center gap-2 transition-colors"
              >
                {loading ? <Loader2 className="animate-spin" size={16} /> : <CheckCircle2 size={16} />}
                Proses & Masukkan ke Database
              </button>
            </div>
          )}

          {/* TAB 3: Input Manual */}
          {activeTab === 'manual' && (
            <form onSubmit={handleManualAdd} className="mt-4 flex-1 space-y-3">
              <div className="grid grid-cols-2 gap-2.5">
                <div>
                  <label className="block text-[11px] font-medium text-[#5B688A] mb-1">
                    Kategori
                  </label>
                  <input
                    type="text"
                    value={manualCat}
                    onChange={(e) => setManualCat(e.target.value)}
                    placeholder="Sanitary & Plumbing"
                    className="w-full px-3 py-2 bg-[#F4F7FC] border border-[#DDE4F0] rounded-xl text-[12.5px]"
                  />
                </div>
                <div>
                  <label className="block text-[11px] font-medium text-[#5B688A] mb-1">
                    Kode Item WMS *
                  </label>
                  <input
                    type="text"
                    value={manualCodeWms}
                    onChange={(e) => setManualCodeWms(e.target.value)}
                    placeholder="1004523"
                    className="w-full px-3 py-2 bg-[#F4F7FC] border border-[#DDE4F0] rounded-xl text-[12.5px]"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-2.5">
                <div>
                  <label className="block text-[11px] font-medium text-[#5B688A] mb-1">
                    Kode NAV
                  </label>
                  <input
                    type="text"
                    value={manualCodeNav}
                    onChange={(e) => setManualCodeNav(e.target.value)}
                    placeholder="NAV-1004523"
                    className="w-full px-3 py-2 bg-[#F4F7FC] border border-[#DDE4F0] rounded-xl text-[12.5px]"
                  />
                </div>
                <div>
                  <label className="block text-[11px] font-medium text-[#5B688A] mb-1">
                    Nama Item Barang *
                  </label>
                  <input
                    type="text"
                    value={manualName}
                    onChange={(e) => setManualName(e.target.value)}
                    placeholder="Wastafel Toto White"
                    className="w-full px-3 py-2 bg-[#F4F7FC] border border-[#DDE4F0] rounded-xl text-[12.5px]"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-2.5">
                <div>
                  <label className="block text-[11px] font-medium text-[#5B688A] mb-1">
                    Stok WMS (Fisik)
                  </label>
                  <input
                    type="number"
                    value={manualStockWms}
                    onChange={(e) => setManualStockWms(Number(e.target.value))}
                    className="w-full px-3 py-2 bg-[#F4F7FC] border border-[#DDE4F0] rounded-xl text-[12.5px]"
                  />
                </div>
                <div>
                  <label className="block text-[11px] font-medium text-[#5B688A] mb-1">
                    Stok NAV (Sistem)
                  </label>
                  <input
                    type="number"
                    value={manualStockNav}
                    onChange={(e) => setManualStockNav(Number(e.target.value))}
                    className="w-full px-3 py-2 bg-[#F4F7FC] border border-[#DDE4F0] rounded-xl text-[12.5px]"
                  />
                </div>
              </div>

              <button
                type="submit"
                className="w-full mt-2 bg-[#16225C] hover:bg-[#1F2E75] text-white py-3 rounded-xl text-[13px] font-semibold flex items-center justify-center gap-2 transition-colors"
              >
                <PlusCircle size={16} /> Simpan Single Item ke Database
              </button>
            </form>
          )}

          {/* Status Message */}
          {statusMessage && (
            <div
              className={`mt-4 p-3 rounded-xl text-[12px] font-medium flex items-center gap-2 ${
                isSuccess
                  ? 'bg-[#E1F5EE] border border-[#0F6E56]/20 text-[#0F6E56]'
                  : 'bg-[#FBE6E7] border border-[#B3131A]/20 text-[#B3131A]'
              }`}
            >
              {isSuccess ? <CheckCircle2 size={18} /> : <AlertCircle size={18} />}
              <span>{statusMessage}</span>
            </div>
          )}

          {/* Preview summary */}
          {previewSummary && (
            <div className="mt-3 p-3 bg-[#FAF9F5] border border-[#DDE4F0] rounded-xl text-[12px]">
              <span className="font-bold text-[#172554] block mb-1">
                Kategori Terimpor ({previewSummary.categoryCount}):
              </span>
              <div className="flex flex-wrap gap-1.5 mt-1">
                {previewSummary.categoryNames.map((c) => (
                  <span
                    key={c}
                    className="bg-[#E5E8F5] text-[#16225C] px-2.5 py-0.5 rounded-md text-[11px] font-semibold"
                  >
                    {c}
                  </span>
                ))}
              </div>
            </div>
          )}

          <div className="mt-5 pt-3 border-t border-[#DDE4F0]">
            <button
              onClick={onBack}
              className="w-full bg-[#F4F7FC] hover:bg-[#EAEEF6] border border-[#DDE4F0] text-[#172554] py-3 rounded-xl text-[13.5px] font-semibold"
            >
              Kembali ke Data Laporan
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

