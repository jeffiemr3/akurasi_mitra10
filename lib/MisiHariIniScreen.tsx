import React, { useState } from 'react';
import { ArrowLeft, Send, CheckCircle2, AlertCircle, Plus, Minus, RotateCcw } from 'lucide-react';
import { DonutChart } from '../components/DonutChart';
import { AuditItem, AuditReport, AppUser } from '../types';

interface MisiHariIniScreenProps {
  currentUser: AppUser;
  categoryName: string;
  initialItems: AuditItem[];
  onBack: () => void;
  onSubmitReport: (report: AuditReport) => void;
}

export const MisiHariIniScreen: React.FC<MisiHariIniScreenProps> = ({
  currentUser,
  categoryName,
  initialItems,
  onBack,
  onSubmitReport,
}) => {
  const [items, setItems] = useState<AuditItem[]>(initialItems);
  const [sending, setSending] = useState(false);
  const [showSuccessToast, setShowSuccessToast] = useState(false);

  // Statistics calculation
  const total = items.length;
  const hitCount = items.filter((i) => i.status === 'HIT').length;
  const missCount = items.filter((i) => i.status === 'MISS').length;
  const overCount = items.filter((i) => i.status === 'OVER').length;
  const needRecheck = missCount + overCount;
  const accuracy = total === 0 ? 0 : (hitCount / total) * 100;

  // Auditor stock adjustment helper
  const handleUpdateWmsStock = (id: string, delta: number) => {
    setItems((prev) =>
      prev.map((item) => {
        if (item.id !== id) return item;
        const newWms = Math.max(0, item.wmsStock + delta);
        let status: 'HIT' | 'MISS' | 'OVER' = 'HIT';
        if (newWms < item.navStock) status = 'MISS';
        else if (newWms > item.navStock) status = 'OVER';

        return {
          ...item,
          wmsStock: newWms,
          status,
        };
      })
    );
  };

  const handleKirimReport = () => {
    setSending(true);
    setTimeout(() => {
      const now = new Date();
      const timestamp = `${now.getDate().toString().padStart(2, '0')}/${(
        now.getMonth() + 1
      )
        .toString()
        .padStart(2, '0')}/${now.getFullYear()} ${now
        .getHours()
        .toString()
        .padStart(2, '0')}.${now.getMinutes().toString().padStart(2, '0')}`;

      const newReport: AuditReport = {
        id: `rep-${Date.now()}`,
        category: categoryName,
        username: currentUser.username,
        total,
        hit: hitCount,
        miss: missCount,
        over: overCount,
        accuracy,
        items,
        sentAt: timestamp,
      };

      onSubmitReport(newReport);
      setSending(false);
      setShowSuccessToast(true);
      setTimeout(() => setShowSuccessToast(false), 3000);
    }, 800);
  };

  return (
    <div className="min-h-screen bg-[#DCE7F7] flex flex-col p-4 sm:p-6">
      <div className="w-full max-w-[640px] mx-auto flex flex-col flex-1">
        {/* Header Bar */}
        <div className="flex items-center gap-3 mb-3">
          <button
            id="btn-misi-back"
            onClick={onBack}
            className="w-8 h-8 rounded-full bg-white border border-[#DDE4F0] flex items-center justify-center text-[#172554] hover:bg-gray-50"
          >
            <ArrowLeft size={16} />
          </button>
          <span className="text-[12px] font-bold tracking-wider text-[#5B688A] uppercase">
            MISI HARI INI
          </span>
        </div>

        {/* Content Card */}
        <div className="bg-white rounded-[28px] p-5 sm:p-7 flex-1 flex flex-col shadow-sm">
          {/* Header Title */}
          <div>
            <span className="text-[11px] font-bold tracking-wider text-[#92670A] uppercase">
              MISI HARI INI
            </span>
            <h1 className="text-[21px] font-bold text-[#172554] mt-0.5">
              Kategori {categoryName}
            </h1>
          </div>

          {/* Accuracy Overview Card */}
          <div className="mt-4 p-4 bg-[#F4F7FC] rounded-[18px] flex items-center gap-4">
            <DonutChart
              hit={hitCount}
              miss={missCount}
              over={overCount}
              accuracy={accuracy}
              size={100}
            />

            <div className="flex-1">
              <span className="text-[16px] font-bold text-[#172554] block">
                {total} item
              </span>
              <div className="mt-2 space-y-1">
                <div className="flex items-center gap-1.5 text-[12.5px] text-[#172554]">
                  <span className="w-2 h-2 rounded-full bg-[#1D9E75]" />
                  <span>{hitCount} hit</span>
                </div>
                <div className="flex items-center gap-1.5 text-[12.5px] text-[#172554]">
                  <span className="w-2 h-2 rounded-full bg-[#B3131A]" />
                  <span>{missCount} miss</span>
                </div>
                <div className="flex items-center gap-1.5 text-[12.5px] text-[#172554]">
                  <span className="w-2 h-2 rounded-full bg-[#F5B301]" />
                  <span>{overCount} over</span>
                </div>
              </div>
            </div>
          </div>

          {/* Recheck Alert Banner */}
          <div className="mt-3 px-3.5 py-2.5 bg-[#EAEEF6] rounded-xl flex items-center gap-2 text-[12.5px] text-[#5B688A]">
            <AlertCircle size={16} className="text-[#5B688A] shrink-0" />
            <span>
              <strong>{needRecheck} item</strong> perlu dicek ulang
            </span>
          </div>

          {/* Audit Items List */}
          <div className="mt-4 flex-1 space-y-2.5 overflow-y-auto max-h-[400px] pr-1">
            {items.map((item) => {
              const badgeBg =
                item.status === 'HIT'
                  ? 'bg-[#E1F5EE] text-[#0F6E56]'
                  : item.status === 'MISS'
                  ? 'bg-[#FBE6E7] text-[#B3131A]'
                  : 'bg-[#FDF1D6] text-[#92670A]';

              return (
                <div
                  key={item.id}
                  className="p-3.5 border border-[#DDE4F0] rounded-2xl flex flex-col sm:flex-row sm:items-center justify-between gap-3 hover:border-[#16225C] transition-colors"
                >
                  <div className="flex-1">
                    <h4 className="text-[13.5px] font-semibold text-[#16225C]">
                      {item.name}
                    </h4>
                    <div className="text-[11px] text-[#5B688A] font-mono mt-0.5">
                      {item.codeWms} · {item.codeNav}
                    </div>
                    <div className="text-[11px] text-[#5B688A] mt-0.5">
                      WMS: <strong className="text-[#172554]">{item.wmsStock}</strong> · NAV:{' '}
                      <strong className="text-[#172554]">{item.navStock}</strong>
                    </div>
                  </div>

                  <div className="flex items-center justify-between sm:justify-end gap-3">
                    {/* Quick Adjust Buttons */}
                    <div className="flex items-center gap-1 bg-[#F4F7FC] border border-[#DDE4F0] rounded-lg p-0.5">
                      <button
                        id={`btn-dec-${item.id}`}
                        onClick={() => handleUpdateWmsStock(item.id, -1)}
                        className="w-6 h-6 rounded flex items-center justify-center text-[#172554] hover:bg-white"
                        title="Kurangi WMS"
                      >
                        <Minus size={13} />
                      </button>
                      <span className="text-[12px] font-bold px-1.5 min-w-[20px] text-center">
                        {item.wmsStock}
                      </span>
                      <button
                        id={`btn-inc-${item.id}`}
                        onClick={() => handleUpdateWmsStock(item.id, 1)}
                        className="w-6 h-6 rounded flex items-center justify-center text-[#172554] hover:bg-white"
                        title="Tambah WMS"
                      >
                        <Plus size={13} />
                      </button>
                    </div>

                    {/* Status Badge */}
                    <span
                      className={`px-2.5 py-1 rounded-full text-[10.5px] font-bold uppercase ${badgeBg}`}
                    >
                      {item.status}
                    </span>
                  </div>
                </div>
              );
            })}
          </div>

          {/* Toast Notification */}
          {showSuccessToast && (
            <div className="mt-3 p-3 bg-[#E1F5EE] border border-[#0F6E56]/20 text-[#0F6E56] rounded-xl text-[13px] font-medium flex items-center gap-2 animate-in fade-in slide-in-from-bottom-2">
              <CheckCircle2 size={16} /> Report berhasil dikirim ke database!
            </div>
          )}

          {/* Submit Button */}
          <div className="mt-5 pt-3 border-t border-[#DDE4F0]">
            <button
              id="btn-kirim-report"
              onClick={handleKirimReport}
              disabled={sending}
              className="w-full bg-[#16225C] hover:bg-[#1F2E75] text-white py-3.5 rounded-full text-[15px] font-semibold flex items-center justify-center gap-2 transition-colors disabled:opacity-50"
            >
              {sending ? (
                <>
                  <RotateCcw className="animate-spin" size={18} /> Mengirim...
                </>
              ) : (
                <>
                  <Send size={18} /> Kirim report
                </>
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
