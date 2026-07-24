import React, { useState } from 'react';
import { ArrowLeft, Download, ChevronRight, Upload, FileCheck, Database, Layers } from 'lucide-react';
import * as XLSX from 'xlsx';
import { ReportDataInfo, AuditReport } from '../types';

interface DataScreenProps {
  reportDataInfos: ReportDataInfo[];
  reports: AuditReport[];
  onBack: () => void;
  onNavigateToUpload: () => void;
}

export const DataScreen: React.FC<DataScreenProps> = ({
  reportDataInfos,
  reports,
  onBack,
  onNavigateToUpload,
}) => {
  const [selectedIdx, setSelectedIdx] = useState(0);
  const [exporting, setExporting] = useState(false);
  const [toastMessage, setToastMessage] = useState('');

  const handleExport = () => {
    const selectedReportInfo = reportDataInfos[selectedIdx];
    if (!selectedReportInfo) return;
    setExporting(true);

    // Build Excel worksheet from real reports data
    const exportRows: any[] = [];
    reports.forEach((rep) => {
      rep.items.forEach((item) => {
        exportRows.push({
          'Kategori': rep.category,
          'Item No WMS': item.codeWms,
          'Kode NAV': item.codeNav,
          'Nama Barang': item.name,
          'Ending Stock WMS': item.wmsStock,
          'Ending Stock NAV': item.navStock,
          'Selisih (WMS - NAV)': item.wmsStock - item.navStock,
          'Status Audit': item.status,
          'Auditor': rep.username,
          'Tanggal Update': rep.sentAt,
        });
      });
    });

    // Generate Excel file
    const ws = XLSX.utils.json_to_sheet(exportRows);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, 'Data Audit Stock');

    const filename = `${selectedReportInfo.name.replace(/\s+/g, '_')}_${Date.now()}.xlsx`;
    XLSX.writeFile(wb, filename);

    setExporting(false);
    setToastMessage(`Berhasil mengeksport file "${filename}"`);
    setTimeout(() => setToastMessage(''), 3500);
  };

  return (
    <div className="min-h-screen bg-[#DCE7F7] flex flex-col p-4 sm:p-6">
      <div className="w-full max-w-[640px] mx-auto flex flex-col flex-1">
        {/* Header Bar */}
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-3">
            <button
              id="btn-data-screen-back"
              onClick={onBack}
              className="w-8 h-8 rounded-full bg-white border border-[#DDE4F0] flex items-center justify-center text-[#172554] hover:bg-gray-50"
            >
              <ArrowLeft size={16} />
            </button>
            <span className="text-[12px] font-bold tracking-wider text-[#5B688A] uppercase">
              DATA LAPORAN
            </span>
          </div>

          <button
            id="btn-goto-upload"
            onClick={onNavigateToUpload}
            className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-[#16225C] text-white rounded-xl text-[12px] font-semibold hover:bg-[#1F2E75] shadow-xs"
          >
            <Upload size={14} /> + Input / Impor Data
          </button>
        </div>

        {/* Content Card */}
        <div className="bg-white rounded-[28px] p-5 sm:p-7 flex-1 flex flex-col shadow-sm">
          <div>
            <h1 className="text-[20px] font-bold text-[#172554]">Database & Laporan Audit</h1>
            <p className="text-[12px] text-[#5B688A] mt-0.5">
              Kelola data stok terintegrasi dan eksport laporan ke file Excel (.xlsx)
            </p>
          </div>

          {/* Database Banner */}
          <div className="mt-4 p-4 bg-[#F4F7FC] border border-[#DDE4F0] rounded-2xl flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-[#E5E8F5] text-[#16225C] flex items-center justify-center font-bold">
                <Database size={20} />
              </div>
              <div>
                <span className="text-[13.5px] font-bold text-[#172554] block">
                  Status Database Stok Local
                </span>
                <span className="text-[11.5px] text-[#0F6E56] font-semibold">
                  ● Aktif & Tersimpan Otomatis
                </span>
              </div>
            </div>

            <button
              onClick={onNavigateToUpload}
              className="px-3 py-1.5 bg-white border border-[#DDE4F0] hover:border-[#16225C] text-[#16225C] rounded-xl text-[11.5px] font-bold shadow-xs"
            >
              Tambah Data
            </button>
          </div>

          {/* List of Report Types */}
          <div className="mt-5 flex-1 space-y-2.5">
            <span className="text-[11px] font-bold text-[#5B688A] uppercase tracking-wider block">
              Pilih Jenis Laporan Eksport:
            </span>
            {reportDataInfos.map((r, i) => {
              const active = i === selectedIdx;
              return (
                <div
                  key={r.id}
                  onClick={() => setSelectedIdx(i)}
                  className={`p-3.5 rounded-2xl border cursor-pointer transition-all flex items-center justify-between ${
                    active
                      ? 'bg-[#EBEEFA] border-[#16225C] shadow-xs'
                      : 'bg-[#FAF9F5] border-[#DDE4F0] hover:border-[#16225C]'
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-lg bg-white border border-[#DDE4F0] flex items-center justify-center text-[#16225C]">
                      <Layers size={16} />
                    </div>
                    <div>
                      <span className="text-[13.5px] font-semibold text-[#172554] block">
                        {r.name}
                      </span>
                      <span className="text-[11px] text-[#5B688A]">
                        Tipe: {r.type} · Update: {r.updatedAt}
                      </span>
                    </div>
                  </div>

                  <ChevronRight
                    size={18}
                    className={active ? 'text-[#16225C]' : 'text-[#5B688A]'}
                  />
                </div>
              );
            })}
          </div>

          {toastMessage && (
            <div className="mt-4 p-3 bg-[#E1F5EE] border border-[#0F6E56]/20 text-[#0F6E56] rounded-xl text-[12.5px] font-medium flex items-center gap-2">
              <FileCheck size={16} /> {toastMessage}
            </div>
          )}

          {/* Export Button */}
          <div className="mt-6 pt-3 border-t border-[#DDE4F0]">
            <button
              id="btn-export-data"
              onClick={handleExport}
              disabled={exporting}
              className="w-full bg-[#16225C] hover:bg-[#1F2E75] text-white py-3.5 rounded-xl text-[14px] font-semibold flex items-center justify-center gap-2 transition-colors shadow-xs"
            >
              <Download size={17} />
              Export {reportDataInfos[selectedIdx]?.name} (XLSX)
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

