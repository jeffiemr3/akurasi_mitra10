import React, { useState } from 'react';
import { ArrowLeft, TrendingUp, CheckCircle, AlertTriangle, HelpCircle, FileText, ChevronRight } from 'lucide-react';
import { ResponsiveContainer, BarChart, Bar, XAxis, YAxis, Tooltip, CartesianGrid } from 'recharts';
import { AuditReport } from '../types';

interface HasilScreenProps {
  reports: AuditReport[];
  onBack: () => void;
}

export const HasilScreen: React.FC<HasilScreenProps> = ({ reports, onBack }) => {
  const [selectedReport, setSelectedReport] = useState<AuditReport | null>(null);

  // Compute aggregate metrics
  const totalReports = reports.length;
  const totalAuditedItems = reports.reduce((acc, r) => acc + r.total, 0);
  const totalHit = reports.reduce((acc, r) => acc + r.hit, 0);
  const totalMiss = reports.reduce((acc, r) => acc + r.miss, 0);
  const totalOver = reports.reduce((acc, r) => acc + r.over, 0);
  const avgAccuracy =
    totalAuditedItems > 0 ? (totalHit / totalAuditedItems) * 100 : 0;

  // Chart data per category
  const chartData = reports.map((r) => ({
    category: r.category.length > 12 ? r.category.substring(0, 12) + '...' : r.category,
    HIT: r.hit,
    MISS: r.miss,
    OVER: r.over,
    accuracy: Math.round(r.accuracy),
  }));

  return (
    <div className="min-h-screen bg-[#DCE7F7] flex flex-col p-4 sm:p-6">
      <div className="w-full max-w-[640px] mx-auto flex flex-col flex-1">
        {/* Header */}
        <div className="flex items-center gap-3 mb-3">
          <button
            id="btn-hasil-back"
            onClick={onBack}
            className="w-8 h-8 rounded-full bg-white border border-[#DDE4F0] flex items-center justify-center text-[#172554] hover:bg-gray-50"
          >
            <ArrowLeft size={16} />
          </button>
          <span className="text-[12px] font-bold tracking-wider text-[#5B688A] uppercase">
            HASIL & ANALITIK AUDIT
          </span>
        </div>

        {/* Content Card */}
        <div className="bg-white rounded-[28px] p-5 sm:p-7 flex-1 flex flex-col shadow-sm">
          <div>
            <h1 className="text-[21px] font-bold text-[#172554]">
              Hasil Stock Audit
            </h1>
            <p className="text-[12px] text-[#5B688A] mt-0.5">
              Rangkuman akurasi stok Mitra10 WMS vs NAV
            </p>
          </div>

          {/* Metric Overview Grid */}
          <div className="mt-4 grid grid-cols-2 sm:grid-cols-4 gap-2.5">
            <div className="p-3 bg-[#E1F5EE] border border-[#0F6E56]/20 rounded-2xl">
              <span className="text-[10px] font-bold text-[#0F6E56] uppercase">Rata-rata Akurasi</span>
              <div className="text-[20px] font-extrabold text-[#0F6E56] mt-0.5">
                {avgAccuracy.toFixed(1)}%
              </div>
            </div>

            <div className="p-3 bg-[#EAEEF6] border border-[#DDE4F0] rounded-2xl">
              <span className="text-[10px] font-bold text-[#16225C] uppercase">Total Item</span>
              <div className="text-[20px] font-extrabold text-[#16225C] mt-0.5">
                {totalAuditedItems}
              </div>
            </div>

            <div className="p-3 bg-[#FBE6E7] border border-[#B3131A]/20 rounded-2xl">
              <span className="text-[10px] font-bold text-[#B3131A] uppercase">Total Miss</span>
              <div className="text-[20px] font-extrabold text-[#B3131A] mt-0.5">
                {totalMiss}
              </div>
            </div>

            <div className="p-3 bg-[#FDF1D6] border border-[#92670A]/20 rounded-2xl">
              <span className="text-[10px] font-bold text-[#92670A] uppercase">Total Over</span>
              <div className="text-[20px] font-extrabold text-[#92670A] mt-0.5">
                {totalOver}
              </div>
            </div>
          </div>

          {/* Bar Chart Section */}
          <div className="mt-5 p-4 bg-[#F4F7FC] border border-[#DDE4F0] rounded-2xl">
            <span className="text-[12px] font-bold text-[#172554] block mb-3">
              Perbandingan Stok Per Kategori
            </span>
            <div className="h-[180px] w-full text-[11px]">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={chartData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#E2E8F0" />
                  <XAxis dataKey="category" tick={{ fill: '#5B688A', fontSize: 10 }} />
                  <YAxis tick={{ fill: '#5B688A', fontSize: 10 }} />
                  <Tooltip />
                  <Bar dataKey="HIT" fill="#1D9E75" radius={[4, 4, 0, 0]} name="HIT" />
                  <Bar dataKey="MISS" fill="#B3131A" radius={[4, 4, 0, 0]} name="MISS" />
                  <Bar dataKey="OVER" fill="#F5B301" radius={[4, 4, 0, 0]} name="OVER" />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Submitted Reports History */}
          <div className="mt-5 flex-1">
            <span className="text-[12px] font-bold text-[#5B688A] uppercase tracking-wider block mb-2.5">
              Laporan Audit Terkini ({totalReports})
            </span>

            <div className="space-y-2 max-h-[220px] overflow-y-auto pr-1">
              {reports.map((rep) => (
                <div
                  key={rep.id}
                  onClick={() => setSelectedReport(rep)}
                  className="p-3 bg-[#FAF9F5] border border-[#DDE4F0] hover:border-[#16225C] rounded-xl flex items-center justify-between cursor-pointer transition-colors"
                >
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-lg bg-[#E5E8F5] text-[#16225C] flex items-center justify-center">
                      <FileText size={16} />
                    </div>
                    <div>
                      <span className="text-[13.5px] font-semibold text-[#172554] block">
                        Kategori {rep.category}
                      </span>
                      <span className="text-[11px] text-[#5B688A]">
                        Oleh @{rep.username} · {rep.sentAt}
                      </span>
                    </div>
                  </div>

                  <div className="flex items-center gap-2">
                    <span className="text-[12.5px] font-bold text-[#0F6E56] bg-[#E1F5EE] px-2.5 py-0.5 rounded-full">
                      {rep.accuracy.toFixed(1)}%
                    </span>
                    <ChevronRight size={16} className="text-[#5B688A]" />
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Report Detail Modal */}
      {selectedReport && (
        <div className="fixed inset-0 bg-black/40 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl p-6 max-w-[480px] w-full max-h-[85vh] overflow-y-auto shadow-xl">
            <div className="flex items-center justify-between border-b border-[#DDE4F0] pb-3">
              <div>
                <h3 className="text-[16px] font-bold text-[#172554]">
                  Laporan Audit {selectedReport.category}
                </h3>
                <span className="text-[11.5px] text-[#5B688A]">
                  Dikirim oleh @{selectedReport.username} ({selectedReport.sentAt})
                </span>
              </div>
              <button
                onClick={() => setSelectedReport(null)}
                className="text-[#5B688A] hover:text-[#172554] text-sm font-bold px-2 py-1"
              >
                ✕
              </button>
            </div>

            <div className="mt-4 space-y-2">
              <span className="text-[12px] font-bold text-[#5B688A] uppercase">Detail Rincian Item:</span>
              {selectedReport.items.map((it) => (
                <div key={it.id} className="p-2.5 border border-[#DDE4F0] rounded-xl text-[12px] flex justify-between items-center">
                  <div>
                    <span className="font-semibold text-[#172554] block">{it.name}</span>
                    <span className="text-[#5B688A] font-mono text-[10.5px]">WMS {it.wmsStock} vs NAV {it.navStock}</span>
                  </div>
                  <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold ${
                    it.status === 'HIT' ? 'bg-[#E1F5EE] text-[#0F6E56]' :
                    it.status === 'MISS' ? 'bg-[#FBE6E7] text-[#B3131A]' : 'bg-[#FDF1D6] text-[#92670A]'
                  }`}>
                    {it.status}
                  </span>
                </div>
              ))}
            </div>

            <button
              onClick={() => setSelectedReport(null)}
              className="w-full mt-5 py-2.5 bg-[#16225C] text-white rounded-xl text-[13px] font-semibold"
            >
              Tutup
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
